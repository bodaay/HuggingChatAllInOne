# Building Back End First
# This Docker file is created by combining Both dockerfiles from these two projects: https://github.com/huggingface/text-generation-inference,https://github.com/huggingface/chat-ui
FROM lukemathwalker/cargo-chef:latest-rust-1.70 AS chef

WORKDIR /usr/src

ARG CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

FROM chef as planner
ARG BackEndSource="Sources/HuggingChat/BackEnd"
COPY ${BackEndSource}/Cargo.toml Cargo.toml
COPY ${BackEndSource}/rust-toolchain.toml rust-toolchain.toml
COPY ${BackEndSource}/proto proto
COPY ${BackEndSource}/benchmark benchmark
COPY ${BackEndSource}/router router
COPY ${BackEndSource}/launcher launcher
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
ARG BackEndSource="Sources/HuggingChat/BackEnd"
ARG GIT_SHA
ARG DOCKER_LABEL

RUN PROTOC_ZIP=protoc-21.12-linux-x86_64.zip && \
    curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v21.12/$PROTOC_ZIP && \
    unzip -o $PROTOC_ZIP -d /usr/local bin/protoc && \
    unzip -o $PROTOC_ZIP -d /usr/local 'include/*' && \
    rm -f $PROTOC_ZIP

COPY --from=planner /usr/src/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

COPY ${BackEndSource}/Cargo.toml Cargo.toml
COPY ${BackEndSource}/rust-toolchain.toml rust-toolchain.toml
COPY ${BackEndSource}/proto proto
COPY ${BackEndSource}/benchmark benchmark
COPY ${BackEndSource}/router router
COPY ${BackEndSource}/launcher launcher
RUN cargo build --release

# Python builder
# Adapted from: https://github.com/pytorch/pytorch/blob/master/Dockerfile
FROM debian:bullseye-slim as pytorch-install
ARG BackEndSource="Sources/HuggingChat/BackEnd"
ARG PYTORCH_VERSION=2.0.0
ARG PYTHON_VERSION=3.9
ARG CUDA_VERSION=11.8
ARG MAMBA_VERSION=23.1.0-1
ARG CUDA_CHANNEL=nvidia
ARG INSTALL_CHANNEL=pytorch
# Automatically set by buildx
ARG TARGETPLATFORM

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        ccache \
        curl \
        git && \
        rm -rf /var/lib/apt/lists/*

# Install conda
# translating Docker's TARGETPLATFORM into mamba arches
RUN case ${TARGETPLATFORM} in \
         "linux/arm64")  MAMBA_ARCH=aarch64  ;; \
         *)              MAMBA_ARCH=x86_64   ;; \
    esac && \
    curl -fsSL -v -o ~/mambaforge.sh -O  "https://github.com/conda-forge/miniforge/releases/download/${MAMBA_VERSION}/Mambaforge-${MAMBA_VERSION}-Linux-${MAMBA_ARCH}.sh"
RUN chmod +x ~/mambaforge.sh && \
    bash ~/mambaforge.sh -b -p /opt/conda && \
    rm ~/mambaforge.sh

# Install pytorch
# On arm64 we exit with an error code
RUN case ${TARGETPLATFORM} in \
         "linux/arm64")  exit 1 ;; \
         *)              /opt/conda/bin/conda update -y conda &&  \
                         /opt/conda/bin/conda install -c "${INSTALL_CHANNEL}" -c "${CUDA_CHANNEL}" -y "python=${PYTHON_VERSION}" pytorch==$PYTORCH_VERSION "pytorch-cuda=$(echo $CUDA_VERSION | cut -d'.' -f 1-2)"  ;; \
    esac && \
    /opt/conda/bin/conda clean -ya

# CUDA kernels builder image
FROM pytorch-install as kernel-builder

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ninja-build \
        && rm -rf /var/lib/apt/lists/*

RUN /opt/conda/bin/conda install -c "nvidia/label/cuda-11.8.0"  cuda==11.8 && \
    /opt/conda/bin/conda clean -ya


# Build Flash Attention CUDA kernels
FROM kernel-builder as flash-att-builder
ARG BackEndSource="Sources/HuggingChat/BackEnd"
WORKDIR /usr/src

COPY ${BackEndSource}/server/Makefile-flash-att Makefile

# Build specific version of flash attention
RUN make build-flash-attention

# Build Transformers CUDA kernels
FROM kernel-builder as custom-kernels-builder
ARG BackEndSource="Sources/HuggingChat/BackEnd"
WORKDIR /usr/src

COPY ${BackEndSource}/server/custom_kernels/ .

# Build specific version of transformers
RUN python setup.py build


# Build vllm CUDA kernels
FROM kernel-builder as vllm-builder

WORKDIR /usr/src

COPY ${BackEndSource}/server/Makefile-vllm Makefile

# Build specific version of vllm
RUN make build-vllm


# Text Generation Inference base image
FROM nvidia/cuda:11.8.0-base-ubuntu20.04 as base
ARG BackEndSource="Sources/HuggingChat/BackEnd"
# Conda env
ENV PATH=/opt/conda/bin:$PATH \
    CONDA_PREFIX=/opt/conda

# Text Generation Inference base env
ENV HUGGINGFACE_HUB_CACHE=/data \
    HF_HUB_ENABLE_HF_TRANSFER=1 \
    PORT=80

WORKDIR /usr/src

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libssl-dev \
        ca-certificates \
        make \
        && rm -rf /var/lib/apt/lists/*

# Copy conda with PyTorch installed
COPY --from=pytorch-install /opt/conda /opt/conda

# Copy build artifacts from flash attention builder
COPY --from=flash-att-builder /usr/src/flash-attention/build/lib.linux-x86_64-cpython-39 /opt/conda/lib/python3.9/site-packages
COPY --from=flash-att-builder /usr/src/flash-attention/csrc/layer_norm/build/lib.linux-x86_64-cpython-39 /opt/conda/lib/python3.9/site-packages
COPY --from=flash-att-builder /usr/src/flash-attention/csrc/rotary/build/lib.linux-x86_64-cpython-39 /opt/conda/lib/python3.9/site-packages

# Copy build artifacts from custom kernels builder
COPY --from=custom-kernels-builder /usr/src/build/lib.linux-x86_64-cpython-39/custom_kernels /usr/src/custom-kernels/src/custom_kernels

# Copy builds artifacts from vllm builder
COPY --from=vllm-builder /usr/src/vllm/build/lib.linux-x86_64-cpython-39 /opt/conda/lib/python3.9/site-packages

# Install flash-attention dependencies
RUN pip install einops --no-cache-dir

# Install server
COPY ${BackEndSource}/proto proto
COPY ${BackEndSource}/server server
COPY ${BackEndSource}/server/Makefile server/Makefile
RUN cd server && \
    make gen-server && \
    pip install -r requirements.txt && \
    pip install ".[bnb, accelerate]" --no-cache-dir

# Install benchmarker
COPY --from=builder /usr/src/target/release/text-generation-benchmark /usr/local/bin/text-generation-benchmark
# Install router
COPY --from=builder /usr/src/target/release/text-generation-router /usr/local/bin/text-generation-router
# Install launcher
COPY --from=builder /usr/src/target/release/text-generation-launcher /usr/local/bin/text-generation-launcher

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        g++ \
        && rm -rf /var/lib/apt/lists/*
        
# AWS Sagemaker compatbile image
FROM base as sagemaker

COPY ${BackEndSource}/sagemaker-entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh



# Final image
FROM base
ARG FrontEndSource="Sources/HuggingChat/FrontEnd"
ENV MONGODB_URL=mongodb://localhost:27017

# Install MongoDB
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget curl gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release python3 \
        ca-certificates \
        make

# Install npm
RUN curl -sL https://deb.nodesource.com/setup_19.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        nodejs nano \
        && rm -rf /var/lib/apt/lists/*

RUN npm install -g vite
RUN npm install -g pm2

RUN curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/mongodb-6.gpg

RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        mongodb-org \
        && rm -rf /var/lib/apt/lists/*


RUN mkdir -p /data/db


# I'll just copy the whole source for web-chat ui into the docker, and build it there

COPY  ${FrontEndSource}/.eslintignore /app/
COPY  ${FrontEndSource}/.eslintrc.cjs /app/
COPY  ${FrontEndSource}/.npmrc /app/
COPY  ${FrontEndSource}/.prettierignore /app/
COPY  ${FrontEndSource}/.prettierrc /app/


COPY  ${FrontEndSource}/LICENSE /app/
COPY  ${FrontEndSource}/package-lock.json /app/
COPY  ${FrontEndSource}/package.json /app/
COPY  ${FrontEndSource}/postcss.config.js /app/
COPY  ${FrontEndSource}/PRIVACY.md /app/
COPY  ${FrontEndSource}/README.md /app/

COPY  ${FrontEndSource}/svelte.config.js /app/
COPY  ${FrontEndSource}/tailwind.config.cjs /app/
COPY  ${FrontEndSource}/tsconfig.json /app/
COPY  ${FrontEndSource}/vite.config.ts /app/

COPY  ${FrontEndSource}/src/ /app/src/
COPY  ${FrontEndSource}/static/ /app/static/

# copy our .env file
COPY .env.local /app/.env

# do a test build, in order even to have all node_modules ready when we re-run in deployment
RUN cd /app/ && npm install && npm run build

# copy our python dymain env variable script generator
COPY dynamic_env_generator.py /app/
COPY patches.json /app/
# I removed this
# ENTRYPOINT ["text-generation-launcher"]
# My Custom Entry Point, starting mongo first,  then web ui,then text-generation
COPY commands.sh /scripts/commands.sh
RUN ["chmod", "+x", "/scripts/commands.sh"]

ENTRYPOINT ["/scripts/commands.sh"]


# CMD ["--json-output"]
