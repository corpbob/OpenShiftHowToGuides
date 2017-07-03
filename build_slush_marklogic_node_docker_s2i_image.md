# How to build slush-marklogic-node Source-2-Image Docker Image

## Clone the s2i repo

```
git clone https://github.com/corpbob/s2i-slush-ml.git
```

## Build the image
```
cd s2i-slush-ml
docker build --rm=true -t slush-marklogic-node .
```
- Check the image has been created

```
[root@openshiftdev s2i-slush-ml]# docker images|grep slush
slush-marklogic-node                         latest              f017d723d97f        18 seconds ago      886.8 MB
```
## Tag and push image to openshift

```
docker tag slush-marklogic-node  172.30.1.1:5000/openshift/slush-marklogic-node

```
- Login to internal docker registry

```
[root@openshiftdev OpenShiftHowToGuides]# docker login -u admin -p $(oc whoami -t) 172.30.1.1:5000
```

