# How to Use the CI/CD Pipeline in OpenShift Origin

## Assumptions:
- OpenShift origin is successfully installed.

## Create the DEV Environment

- Create a new project named todo-dev
- Click on Add To Project and search for mongodb. Select mongodb-persistent
- Configure mongodb settings. Set the following:
Database Service Name: mongodb
Database UserName: demo
Database Password: demo
Database Admin Password: demo
Database name: todo-api


<img src="images/cicd_mongodb_settings.png" height="400px">

- Click OK.

- Click on Add To Project and search for nodejs. Select the one at the left:

<img src="images/cicd_node_js.png" height=400px>

- Configure NodeJS settings. Set the name and git url:

```
Name: todo
Git URL: https://github.com/corpbob/todoAPIjs.git
```

<img src="images/cicd_nodejs_settings1.png" height=400px>

- Click on "advanced options". Scroll to Deployment Options and add the environment variable below:

```
PORT = 8080
```

<img src="images/cicd_nodejs_settings2.png" height=400px>

- Wait for the deployment of node.js to complete. After completion, click on the link as shown below to show you the application.

<img src="images/cicd_todo_route.png" height=400px>

- This should be you the application page like the one below. You can try to input "tasks" and explore the application.

<img src="images/cicd_todo_web.png" height=400px>

- Click on Add to Project. Search for jenkins-persistent

<img src="images/cicd_jenkins_persistent.png" height=400px>

- Copy the following pipeline definition to a file todo_pipeline.yml

```
apiVersion: v1
kind: BuildConfig
metadata:
  labels:
    app: jenkins-pipeline-example
    name: sample-pipeline
    template: application-template-sample-pipeline
  name: todo-pipeline
spec:
  runPolicy: Serial
  strategy:
    jenkinsPipelineStrategy:
      jenkinsfile: |-
        node('nodejs') {
          stage('build') {
            openshiftBuild(buildConfig: 'todo', showBuildLogs: 'true')
          }
          stage('deploy') {
            openshiftDeploy(deploymentConfig: 'todo')
          }
 
          stage( 'Wait for approval')
          input( 'Aprove to production?')
          stage('Deploy UAT'){
            openshiftDeploy(deploymentConfig: 'todo', namespace: 'todo-uat2')
          }

        }
    type: JenkinsPipeline
  triggers:
  - github:
      secret: secret101
    type: GitHub
  - generic:
      secret: secret101
    type: Generic
```
- Import this definition to the todo-dev project

```
oc login -u admin -p admin
oc project todo-dev
oc create -f todo_pipeline.yml
```

- Open the Pipeline Page. Click on Build->Pipelines as show below:

<img src="images/cicd_pipeline_navigate.png" height=400px>

<img src="images/cicd_pipeline_empty.png" height=200px>


