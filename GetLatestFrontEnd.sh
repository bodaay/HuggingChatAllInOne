#!/bin/bash

SourceFolder="Sources/HuggingChat/FrontEnd"
rm -rf $SourceFolder

git clone https://github.com/huggingface/chat-ui $SourceFolder