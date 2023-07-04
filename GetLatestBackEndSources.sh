#!/bin/bash


DockerUserCommit="1da07e85aae8ce417dda3effd516691394dc31a1"



SourceFolder="Sources/HuggingChat/BackEnd"
#rm -rf $SourceFolder

git clone https://github.com/huggingface/text-generation-inference $SourceFolder

cd $SourceFolder
git checkout $DockerUserCommit
cd -