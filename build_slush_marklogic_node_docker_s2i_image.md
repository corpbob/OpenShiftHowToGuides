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

- Push image to repository

```
docker push 172.30.1.1:5000/openshift/slush-marklogic-node

The push refers to a repository [172.30.1.1:5000/openshift/slush-marklogic-node]
4e1c82c1b725: Pushed 
9bae9189a217: Pushed 
4ebcaa059048: Pushed 
683992e67126: Pushed 
017d70e0e599: Pushed 
cb96aea742c3: Mounted from ml2/slush-marklogic-app 
f1bbaf33b49c: Mounted from ml2/slush-marklogic-app 
4b1e8db0189a: Mounted from ml2/slush-marklogic-app 
34e7b85d83e4: Mounted from ml2/slush-marklogic-app 
latest: digest: sha256:6d3537b85e44da95d35dd830e032dfb507c2c057030c4f3b501dc7e5d6904e46 size: 17516
```
- Check that the ImageStream is in openshift

```
[root@openshiftdev OpenShiftHowToGuides]# oc get is -n openshift|grep slush
slush-marklogic-node   172.30.1.1:5000/openshift/slush-marklogic-node   latest                         50 seconds ago
```

- You can also view the ImageStream config generated
```
[root@openshiftdev OpenShiftHowToGuides]# oc export is slush-marklogic-node -n openshift
apiVersion: v1
kind: ImageStream
metadata:
  creationTimestamp: null
  generation: 1
  name: slush-marklogic-node
spec:
  tags:
  - annotations: null
    from:
      kind: DockerImage
      name: 172.30.1.1:5000/openshift/slush-marklogic-node:latest
    generation: null
    importPolicy: {}
    name: latest
    referencePolicy:
      type: ""
status:
  dockerImageRepository: ""
```
# Congratulations! You have build the slush-marklogic-node s2i builder image!
