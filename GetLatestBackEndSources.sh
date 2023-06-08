#!/bin/bash

SourceFolder="Sources/HuggingChat/BackEnd"
rm -rf $SourceFolder

git clone https://github.com/huggingface/text-generation-inference $SourceFolder