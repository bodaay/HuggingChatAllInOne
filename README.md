# Why

Trying to build All in one docker to run HuggingChat Front and Back end in runpod.io

and the ability to run this docker in offline enviroment to test out lang models with multiple people

The most difficult part was the fact .env variable parameters, some of them, were being integrated at build time, this made me choose the easiset path, dynamically generate .env variable and re-build the website at run time.
In addition, I've checking if this is running under RunPOD.io, so I'll be setting the parameter PUBLIC_ORIGIN automatically (thankfully runpod.io providing env variable called RUNPOD_POD_ID)

# To Build

Building the docker image will take really long time...

```
./UpdateAllSources.sh
./BuildAllInOneDockerFile.sh
```

# to Run 
```
docker run --gpus all -p 8080:80 -p 27017:27017 -p 1129:1129 -v $PWD/Data:/data -e PUBLIC_ORIGIN="http://localhost:8080" -e MODEL_ID='TheBloke/Wizard-Vicuna-7B-Uncensored-HF' ghcr.io/bodaay/huggingchatallinone/hugging-chat-full:1.0
```