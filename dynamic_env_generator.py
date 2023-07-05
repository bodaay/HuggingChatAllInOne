import json
import os

target_file="/app/.env"

EnvVariable = {}
EnvVariable['MONGODB_URL'] = os.environ['MONGODB_URL'] if 'MONGODB_URL' in os.environ else "mongodb://localhost:27017" 
EnvVariable['MONGODB_DB_NAME'] = os.environ['MONGODB_DB_NAME'] if 'MONGODB_DB_NAME' in os.environ else "bodaay-chat-ui" 
EnvVariable['MONGODB_DIRECT_CONNECTION'] = os.environ['MONGODB_DIRECT_CONNECTION'] if 'MONGODB_DIRECT_CONNECTION' in os.environ else False

EnvVariable['COOKIE_NAME'] = os.environ['COOKIE_NAME'] if 'COOKIE_NAME' in os.environ else "hfall-chat" 

EnvVariable['HF_ACCESS_TOKEN'] = os.environ['HF_ACCESS_TOKEN'] if 'HF_ACCESS_TOKEN' in os.environ else ""

EnvVariable['SERPAPI_KEY'] = os.environ['SERPAPI_KEY'] if 'SERPAPI_KEY' in os.environ else ""


EnvVariable['OPENID_CLIENT_ID'] = os.environ['OPENID_CLIENT_ID'] if 'OPENID_CLIENT_ID' in os.environ else ""
EnvVariable['OPENID_CLIENT_SECRET'] = os.environ['OPENID_CLIENT_SECRET'] if 'OPENID_CLIENT_SECRET' in os.environ else ""
EnvVariable['OPENID_SCOPES'] = os.environ['OPENID_SCOPES'] if 'OPENID_SCOPES' in os.environ else ""
EnvVariable['OPENID_PROVIDER_URL'] = os.environ['OPENID_PROVIDER_URL'] if 'OPENID_PROVIDER_URL' in os.environ else ""




EnvVariable['PUBLIC_SHARE_PREFIX'] = os.environ['PUBLIC_SHARE_PREFIX'] if 'PUBLIC_SHARE_PREFIX' in os.environ else ""
EnvVariable['PUBLIC_GOOGLE_ANALYTICS_ID'] = os.environ['PUBLIC_GOOGLE_ANALYTICS_ID'] if 'PUBLIC_GOOGLE_ANALYTICS_ID' in os.environ else ""
EnvVariable['PUBLIC_DEPRECATED_GOOGLE_ANALYTICS_ID'] = os.environ['PUBLIC_DEPRECATED_GOOGLE_ANALYTICS_ID'] if 'PUBLIC_DEPRECATED_GOOGLE_ANALYTICS_ID' in os.environ else ""
EnvVariable['PUBLIC_ANNOUNCEMENT_BANNERS'] = os.environ['PUBLIC_ANNOUNCEMENT_BANNERS'] if 'PUBLIC_ANNOUNCEMENT_BANNERS' in os.environ else ""

EnvVariable['PARQUET_EXPORT_DATASET'] = os.environ['PARQUET_EXPORT_DATASET'] if 'PARQUET_EXPORT_DATASET' in os.environ else ""
EnvVariable['PARQUET_EXPORT_HF_TOKEN'] = os.environ['PARQUET_EXPORT_HF_TOKEN'] if 'PARQUET_EXPORT_HF_TOKEN' in os.environ else ""
EnvVariable['PARQUET_EXPORT_SECRET'] = os.environ['PARQUET_EXPORT_SECRET'] if 'PARQUET_EXPORT_SECRET' in os.environ else ""


############################## now custom parameters time

MODELS=[]

# Maybe later on I'll support multiple models, now, seriously, no way in hell I'm doing it
Model_One = {}

Model_One['endpoints'] = [{"url": "http://localhost:1129/generate_stream","authorization": "Basic VVNFUjpQQVNT"}]


Model_One['name'] = os.environ['MODEL_ID'] if 'MODEL_ID' in os.environ else "TheBloke/Wizard-Vicuna-7B-Uncensored-HF"

Model_One['userMessageToken'] = os.environ['USER_MESSAGE_TOKEN'] if 'USER_MESSAGE_TOKEN' in os.environ else "USER: "
Model_One['assistantMessageToken'] = os.environ['BOT_MESSAGE_TOKEN'] if 'BOT_MESSAGE_TOKEN' in os.environ else "ASSISTANT:"
Model_One['messageEndToken'] = os.environ['END_MESSAGE_TOKEN'] if 'END_MESSAGE_TOKEN' in os.environ else "<|eostoken|>"
Model_One['preprompt'] = os.environ['PREPROMPT'] if 'PREPROMPT' in os.environ else "Below are a series of dialogues between various people and an AI assistant. The AI tries to be helpful, polite, honest, sophisticated, emotionally aware, and humble-but-knowledgeable. The assistant is happy to help with almost anything, and will do its best to understand exactly what is needed. It also tries to avoid giving false or misleading information, and it caveats when it isn't entirely sure about the right answer. That said, the assistant is practical and really does its best, and doesn't let caution get too much in the way of being useful.\n-----\n"
Model_One['parameters']={}
Model_One['parameters']['temperature'] = os.environ['TEMPERATURE'] if 'TEMPERATURE' in os.environ else 0.9
Model_One['parameters']['top_p'] = os.environ['TOP_K'] if 'TOP_K' in os.environ else 0.95
Model_One['parameters']['repetition_penalty'] = os.environ['REPETITION_PENALTY'] if 'REPETITION_PENALTY' in os.environ else 1.2
Model_One['parameters']['top_k'] = os.environ['TOP_K'] if 'TOP_K' in os.environ else 1
Model_One['parameters']['truncate'] = os.environ['TRUNCATE'] if 'TRUNCATE' in os.environ else 1000
Model_One['parameters']['max_new_tokens'] = os.environ['MAX_NEW_TOKENS'] if 'MAX_NEW_TOKENS' in os.environ else 1024

MODELS.append(Model_One)
models_string=json.dumps(MODELS,indent=2)


#funny all of this extra work because of this stupid parameter PUBLIC_ORIGIN
#check if we are running this under RunPOD, if this is correct, we can simply replace PUBLIC_ORIGIN with correct address
EnvVariable['PUBLIC_ORIGIN'] = os.environ['PUBLIC_ORIGIN'] if 'PUBLIC_ORIGIN' in os.environ else "http://localhost:8080"
if 'RUNPOD_POD_ID' in os.environ:
    EnvVariable['PUBLIC_ORIGIN']="https://%s-8080.proxy.runpod.net"%(os.environ['PUBLIC_ORIGIN'])


with open(target_file, 'w') as f:
    for key, value in EnvVariable.items():
        if isinstance(value, bool):
            # convert boolean to lower case string
            f.write(f'{key}={str(value).lower()}\n')
        else:
            f.write(f'{key}={value}\n')
    f.write(f'MODELS=`{models_string}`\n')
    f.write(f'OLD_MODELS=`[]`\n')
