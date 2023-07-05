# Why

I like HuggingChat UI, and their text generation infra structure, so wanted to build All in one docker to run HuggingChat Front and Back end in on docker and on runpod.io
and it should be fairly easilt to run this single docker offline given the models already downloaded

The most difficult part was the fact .env variable parameters, some of them, were being integrated at build time, this made me choose the easiset path, dynamically generate .env variable and re-build the website at run time.
In addition, Im checking if this is running under RunPOD.io, so I'll be setting the parameter PUBLIC_ORIGIN automatically (thankfully runpod.io providing env variable called RUNPOD_POD_ID)



# To Build

Building the docker image will take really long time...

```
./UpdateAllSources.sh
./BuildAllInOneDockerFile.sh
``` 

# to Run 
```
docker run --gpus all -p 8080:8080 -v $PWD/Data:/data -e PUBLIC_ORIGIN="http://localhost:8080" -e MODEL_ID='TheBloke/Wizard-Vicuna-7B-Uncensored-HF' ghcr.io/bodaay/huggingchatallinone:latest
```

# Runpod Template 
```
https://runpod.io/gsc?template=k8qitdzihe&ref=8s08lrw8
```



## Environment Variables

| Variable Name                         | Default Value                                                  |
| ------------------------------------- | -------------------------------------------------------------- |
| MONGODB_URL                           | mongodb://localhost:27017                                      |
| MONGODB_DB_NAME                       | bodaay-chat-ui                                                 |
| MONGODB_DIRECT_CONNECTION             | False                                                          |
| COOKIE_NAME                           | hfall-chat                                                     |
| HF_ACCESS_TOKEN                       |                                                                |
| SERPAPI_KEY                           |                                                                |
| OPENID_CLIENT_ID                      |                                                                |
| OPENID_CLIENT_SECRET                  |                                                                |
| OPENID_SCOPES                         |                                                                |
| OPENID_PROVIDER_URL                   |                                                                |
| PUBLIC_SHARE_PREFIX                   |                                                                |
| PUBLIC_GOOGLE_ANALYTICS_ID            |                                                                |
| PUBLIC_DEPRECATED_GOOGLE_ANALYTICS_ID |                                                                |
| PUBLIC_ANNOUNCEMENT_BANNERS           |                                                                |
| PARQUET_EXPORT_DATASET                |                                                                |
| PARQUET_EXPORT_HF_TOKEN               |                                                                |
| PARQUET_EXPORT_SECRET                 |                                                                |
| PUBLIC_ORIGIN                         | http://localhost:8080                                          |
| MODEL_ID                              | TheBloke/Wizard-Vicuna-7B-Uncensored-HF                        |
| USER_MESSAGE_TOKEN                    | USER:                                                    |
| BOT_MESSAGE_TOKEN                     | ASSISTANT:                                                  |
| END_MESSAGE_TOKEN                     | <\/s>                                                   |
| PREPROMPT                             | Below are a series of dialogues between various people and an AI assistant. The AI tries to be helpful, polite, honest, sophisticated, emotionally aware, and humble-but-knowledgeable. The assistant is happy to help with almost anything, and will do its best to understand exactly what is needed. It also tries to avoid giving false or misleading information, and it caveats when it isn't entirely sure about the right answer. That said, the assistant is practical and really does its best, and doesn't let caution get too much in the way of being useful.\n-----\n |
| TEMPERATURE                           | 0.9                                                            |
| TOP_P                                 | 0.95                                                           |
| TOP_K                                 | 50                                                             |
| REPETITION_PENALTY                    | 1.2                                                            |
| TRUNCATE                              | 1000                                                           |
| MAX_NEW_TOKENS                        | 1024  

* Note that PUBLIC_ORIGIN will be automatically overwritten if you are running this under runpod.io