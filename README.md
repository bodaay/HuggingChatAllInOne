# to Run

docker run --gpus all -p 8080:80 -p 27017:27017 -p 1129:1129 -v $PWD/Data:/data -e MAX_TOTAL_TOKENS=8000 -e MODEL_ID='TheBloke/Wizard-Vicuna-7B-Uncensored-HF' khalefa/hugging-chat-full:1.0
