# How to build MarkLogic docker image

## Pre-requisites

- Let $PWD be the present working directory.
- Create a directory ```tmp``` in $PWD.
- Download MarkLogic rpm from https://developer.marklogic.com/download/binaries/9.0/MarkLogic-9.0-1.1.x86_64.rpm
- Once downloaded, move the file to ```$PWD/tmp``` directory and rename it as ```MarkLogic9.rpm```

## Building the image
- Download the Dockerfile from this link [Dockerfile](marklogic/Dockerfile) to $PWD.
```
curl https://raw.githubusercontent.com/corpbob/OpenShiftHowToGuides/marklogic/marklogic/Dockerfile -o Dockerfile
```

- Download the [initialize-ml.sh](marklogic/initialize-ml.sh) to $PWD.

```
curl https://raw.githubusercontent.com/corpbob/OpenShiftHowToGuides/marklogic/marklogic/initialize-ml.sh -o initialize-ml.sh
```

- Build the docker image  using the command:
```
docker build --rm=true -t marklogic9 .
```
- Check if the docker images was created

```
[root@openshiftdev tmp2]# docker images|grep marklogic9
marklogic9                                   latest              60784656367c        41 seconds ago      1.809 GB

```
# Congratulations! You have just build the MarkLogic9 Docker Image!
