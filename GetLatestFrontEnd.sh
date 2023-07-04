#!/bin/bash

#Its better to keep this, this repo has to be maintaned properly and I cannot just assume there latest changes will not impact the docker image
DockerUserCommit="0aa57debc7f7ffecccb8dc16b2f4b35816fbd817"

SourceFolder="Sources/HuggingChat/FrontEnd"
#rm -rf $SourceFolder

git clone https://github.com/bodaay/chat-ui $SourceFolder


cd $SourceFolder
git checkout $DockerUserCommit
cd -