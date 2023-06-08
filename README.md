# to Run

docker run --gpus all -p 8080:8080 -v $PWD/Data:/data -e 'ENV'=1 -e MODEL_ID='bigscience/bloom-560m' khalefa/hugging-chat-full:1.0

# below might work in the future, when they actually do support AutoGPTQ
docker run --gpus all -p 8080:80 -v $PWD/Data:/data -e 'ENV'=1 -e MODEL_ID='TheBloke/wizardLM-7B-GPTQ' -e QUANTIZE='bitsandbytes' khalefa/hugging-chat-full:1.0

docker run --gpus all -p 8080:80 -v $PWD/Data:/data -e 'ENV'=1 -e MODEL_ID='TheBloke/wizardLM-7B-GPTQ' -e QUANTIZE='gptq' khalefa/hugging-chat-full:1.0

# Below for cluster, just keeping it for ref, not test and I dont its working
# Master, 29500 is the master communication port
docker run --gpus all -p 29500:29500 -p 8080:80  -v $PWD/Data:/data khalefa/hugging-chat-full:1.0

# Any Other Node
docker run --gpus all -p 8081:80 -v $PWD/Data:/data khalefa/hugging-chat-full:1.0