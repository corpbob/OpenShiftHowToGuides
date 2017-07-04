# How to Develop MarkLogic Applications in OpenShift

## Assumptions
- You have installed OpenShift. Instructions here:
  - [install_openshift_origin_single_node.md](install_openshift_origin_single_node.md)
  - [install_openshift_origin_single_node_aws.md](install_openshift_origin_single_node_aws.md)
- You have started OpenShift.
```
oc cluster up \
--public-hostname=10.1.2.2 --routing-suffix=10.1.2.2.nip.io \
--host-data-dir=/var/lib/origin/openshift.local.data
```

- You are logged in to OpenShift as admin

```
[root@openshiftdev OpenShiftHowToGuides]# oc whoami
admin
```

- If not, then log in as admin

```
[root@openshiftdev ~]# oc login -u admin
Logged into "https://10.0.2.15:8443" as "admin" using existing credentials.

You have access to the following projects and can switch between them with 'oc project <projectname>':

  * default
    kube-system
    myproject
    openshift
    openshift-infra

Using project "default".
```

## Build the MarkLogic 9 Docker Image 

- Instructions are here [build_marklogic_docker_image](build_marklogic_docker_image.md)

## Push the MarkLogic Docker image to OpenShift namespace

- Tag it first

```
docker tag marklogic9 172.30.1.1:5000/openshift/marklogic9
```

- Login to internal docker registry
```
docker login -u admin -p $(oc whoami -t) 172.30.1.1:5000
```

- Push the image 
```
[root@openshiftdev ~]# docker push 172.30.1.1:5000/openshift/marklogic9
The push refers to a repository [172.30.1.1:5000/openshift/marklogic9]
ed592544bda0: Pushed 
c4d1a54cbe8c: Pushed 
109dc775307d: Pushed 
12d0ed825c00: Pushed 
a2183695d4bf: Pushed 
88fee9aaa960: Pushed 
dc1e2dcdc7b6: Layer already exists 
latest: digest: sha256:47319f54d674621a27ea90dc6c86edb0fe3db0b20184bf3b9a91b417e3f8f1ea size: 9964

```
- This should create an ImageStream in the openshift namespace. You can check this by issuing the command:

```
[root@openshiftdev OpenShiftHowToGuides]# oc get is -n openshift|grep marklogic
marklogic9   172.30.1.1:5000/openshift/marklogic9   latest                         About a minute ago
```

- You can view the contents of the ImageStream config file by issuing this command:

```
[root@openshiftdev ~]# oc export is marklogic9 -n openshift
apiVersion: v1
kind: ImageStream
metadata:
  creationTimestamp: null
  generation: 1
  name: marklogic9
spec:
  tags:
  - annotations: null
    from:
      kind: DockerImage
      name: 172.30.1.1:5000/openshift/marklogic9:latest
    generation: null
    importPolicy: {}
    name: latest
    referencePolicy:
      type: ""
status:
  dockerImageRepository: ""
```
## Build the slush-marklogic-node Source-2-Image Docker Image 
- Instructions are here [build_slush_marklogic_node_docker_s2i_image.md](build_slush_marklogic_node_docker_s2i_image.md)

## Create DEV environment

- Download the file [slush-marklogic-node-templatel.yml](marklogic/slush-marklogic-node-templatel.yml)

```
curl https://raw.githubusercontent.com/corpbob/OpenShiftHowToGuides/marklogic/marklogic/slush-marklogic-node-templatel.yml -o slush-marklogic-node-templatel.yml
```

- Create dev project

```
oc new-project ml-dev
```

- Allow MarkLogic to run as root user.
```
oc adm policy add-scc-to-user anyuid -z default
```

- Save the docker credentials for pushing and pulling
```
oc secrets new-dockercfg push-secret --docker-server=172.30.1.1:5000 --docker-username=admin --docker-password=$(oc whoami -t) --docker-email=admin@example.com
oc secrets add serviceaccount/default secrets/push-secret --for=pull,mount
```

- Import the template
```
oc create -f slush-marklogic-node-templatel.yml
```

- Create a new app

```
oc new-app slush-marklogic-node-app
```
- After completion, your console should look like the following:

![slush-marklogic-node-overview.png](images/slush-marklogic-node-overview.png)

- Import the pipeline. Download the file [slush-marklogic-node-pipeline.yml](marklogic/slush-marklogic-node-pipeline.yml)
- Issue the command

```
oc create -f slush-marklogic-node-pipeline.yml 
```
You should see a jenkins service was added:

![images/ml-node-dev-cicd.png](images/ml-node-dev-cicd.png)

Navigate to the pipeline to see it:

![images/ml-node-navigate-pipeline.png](images/ml-node-navigate-pipeline.png)

The pipeline that is yet to be started looks like:

![images/ml-node-pipeline-1.png](images/ml-node-pipeline-1.png)

However, we cannot start this yet. We need to create the UAT Environment.


## Create UAT Environment

- Download the file [slush-marklogic-node-templatel-uat.yml(marklogic/slush-marklogic-node-templatel-uat.yml)
- Create uat project

```
oc new-project ml-uat
```

- Allow MarkLogic to run as root user.
```
oc adm policy add-scc-to-user anyuid -z default
```

- Save the docker credentials for pushing and pulling
```
oc secrets new-dockercfg push-secret --docker-server=172.30.1.1:5000 --docker-username=admin --docker-password=$(oc whoami -t) --docker-email=admin@example.com
oc secrets add serviceaccount/default secrets/push-secret --for=pull,mount
```

- Import the template
```
oc create -f slush-marklogic-node-templatel-uat.yml
```

- Create a new app

```
oc new-app slush-marklogic-node-app
```
- After completion, your console should look like the following:

TODO: this image should be uat environment.
![slush-marklogic-node-uat-overview.png](images/slush-marklogic-node-uat-overview.png)


### We need to give jenkins service account in mlnode project edit access to mlnode-uat

```
[root@localhost marklogic]# oc policy add-role-to-user edit system:serviceaccount:ml-dev:jenkins -n ml-uat
role "edit" added: "system:serviceaccount:ml-dev:jenkins"
```
# Running the CI/CD Pipeline

If you click on the jenkins like you'll find the pipeline:

![images/ml-node-jenkins-1.png](images/ml-node-jenkins-1.png)

## Start the pipeline

![images/ml-node-start-pipeline-2.png](images/ml-node-start-pipeline-2.png)

You can also look at the jenkins log:

![images/ml-node-start-pipeline-3.png](images/ml-node-start-pipeline-3.png)

## Wait for Approval

At this stage the pipeline will wait for an Approver to give the go-signal.

![images/ml-node-pipeline-wait-approval.png](images/ml-node-pipeline-wait-approval.png)

## Click on Approve to deploy to UAT

![images/ml-node-pipeline-approval.png](images/ml-node-pipeline-approval.png)

## Pipeline Deploying to UAT

![images/ml-node-pipeline-deploy-uat.png](images/ml-node-pipeline-deploy-uat.png)

## Congratulations! You just deployed to UAT using the pipeline!

![images/ml-node-pipeline-uat-deployed.png](images/ml-node-pipeline-uat-deployed.png)

## Click on the route above to launch the slush-marklogic-node app. You shoud see something like this:

![images/slush-marklogic-node-app-page.png](images/slush-marklogic-node-app-page.png)

## Login the the application using credentials

```
username: admin
password: admin
```
![images/slush-marklogic-node-app-login.png](images/slush-marklogic-node-app-login.png)

## Click on the search menu to get the following:

![images/slush-marklogic-node-app-search.png](images/slush-marklogic-node-app-search.png)

# Congratulations you have now completed CI/CD setup of MarkLogic on OpenShift!
