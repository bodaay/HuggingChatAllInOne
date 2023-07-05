#!/bin/bash


DockerUserCommit="31e2253ae721ea80032283b9e85ffe51945e5a55"



SourceFolder="Sources/HuggingChat/BackEnd"
#rm -rf $SourceFolder

git clone https://github.com/huggingface/text-generation-inference $SourceFolder

cd $SourceFolder
git checkout $DockerUserCommit
cd -