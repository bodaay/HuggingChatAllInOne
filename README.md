# Why

Trying to build All in one docker to run HuggingChat Front and Back end in runpod.io

and the ability to run this docker in offline enviroment to test out lang models with multiple people

# To Build

```
./UpdateAllSources.sh
./BuildAllInOneDockerFile.sh
```

# to Run
```
docker run --gpus all -p 8080:80 -p 27017:27017 -p 1129:1129 -v $PWD/Data:/data -e MAX_TOTAL_TOKENS=8000 -e MODEL_ID='TheBloke/Wizard-Vicuna-7B-Uncensored-HF' khalefa/hugging-chat-full:1.0
```