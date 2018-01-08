# Using CICD Pipeline Part 2

## Objectives:
- Setup Gogs git service. 
- Trigger Jenkins build using a Gogs Git Hook.
- Automatically tag the ImageStream using the git tag supplied by the developer upon pushing to Git.

## Assumptions
- You have setup the CI/CD from this link [using_cicd_pipeline.md](using_cicd_pipeline.md)

## Setup Gogs

- Create a new project called gogs
```
oc new-project gogs
```
- Install persistent PostgreSQL. Set postgresql username, password and database to _gogs_.

- Pull the image first
```
docker pull wkulhanek/gogs:11.4
```
- Create the gogs application
```
oc new-app wkulhanek/gogs:11.4
```
- Attach storage to gogs and mount to /data
- Configure the gogs database by accessing the gogs url. TODO: Add detailed steps.
- Get the contents of /opt/gogs/custom/conf/app.ini
```
[root@openshift todoAPIjs]# oc project gogs
[root@openshift todoAPIjs]# oc get pods
NAME                 READY     STATUS    RESTARTS   AGE
gogs-3-t3wqs         1/1       Running   0          9h
postgresql-1-7969q   1/1       Running   0          10h
```
- Take note of the pod and get the contents of /opt/gogs/custom/conf/app.ini.
```
oc rsh gogs-3-t3wqs cat /opt/gogs/custom/conf/app.ini
```

- Create a config map with key "app.ini" and value equal to the contents of /opt/gogs/custom/conf/app.ini. This will redeploy the gogs application. TODO: Add detailed steps.
- Clone the application https://github.com/corpbob/todoAPIjs.git
```
git clone https://github.com/corpbob/todoAPIjs.git
```
- Login to gogs and create a new repository named todoAPIjs. Make it private.
- Add a new remote 
```
cd todoAPIjs
git remote add gogs <your gogs todoAPIjs repository url>
git push gogs master
```
## Configure gogs secret in OpenShift
- Make sure you are in project todo-dev
```
oc project todo-dev
```

- Create basic secret by specifying your username and password to gogs. In the command below, substitute your gogs username and gogs password.
```
oc secrets new-basicauth  gogs-secret --username=<your gogs username> --password=<your gogs password>
```

## Configure the Deployment Config
- Login to OpenShift web console as admin.
- Navigate to project todo-dev-> Builds -> Builds -> todo.
- Click Actions -> Edit YAML
- Find the following config:
```
  source:
    type: Git
    git:
      uri: 'http://gogs-gogs.10.1.2.2.nip.io/bcorpus/todoAPIjs.git'
      ref: master
 ```
 
 and change to 
 
 ```
   source:
    type: Git
    git:
      uri: 'http://gogs-gogs.10.1.2.2.nip.io/bcorpus/todoAPIjs.git'
      ref: master
    sourceSecret:
      name: gogs-secret
```

## Configure GitHook
- Login to Jenkins as admin
- Click on admin at the upper right hand corner.
- Click on Configure at the left hand navigation bar. 
- Click on Show API Token. Take note of the "User ID" and "API Token". 
- Access the todoAPIjs repository -> Settings -> Git Hooks -> Post Receive. Paste the following script after substituting the user id and api token you got from Jenkins.

```
#!/bin/bash
while read oldrev newrev ref
do
    if [[ $ref =~ refs/tags ]];
    then
        echo "Master ref received.  Deploying master branch to production..."
        TAG=`echo $ref|sed 's#refs/tags/\(.*\)#\1#g'`
        curl -v -k --user <userid>:<api token> -G "https://jenkins-todo-dev.10.1.2.2.nip.io/job/todo-dev-todo-pipeline/buildWithParameters" -d token=secret -d commit=$newrev -d tag=$TAG
    else
        echo "Ref $ref successfully received.  Doing nothing: only the master branch may be deployed on this server."
    fi
done
```

## Configure Jenkins

- Login to Jenkins
- Click on todo-dev/todo-pipeline
- Click on Configure
- Tick  "This Project is Parametrized"
- Add the following string parameters
  - tag
  - commit
- Tick "Trigger Builds Remotely". Set the token to _secret_.
- Modify the pipeline script
```
node('nodejs') {
  stage('build') {
    openshiftBuild(buildConfig: 'todo', showBuildLogs: 'true', commitID: params.commit)
  }
  stage( 'Wait for approval')
  input( 'Aprove to production?')
  stage('Deploy UAT'){
    openshiftTag(sourceStream: 'todo', sourceTag: 'latest', destinationStream: 'todo', destinationTag: params.tag)
  }
}
```

## Test the setup
- In the project todoAPIjs, modify the README file by adding any character/word.
- Execute the following code. The tag should be relevant to your organization.
```
git add README
git commit -m "test"
git tag TestReady-1.0
git push gogs TestReady-1.0
```
- Verify that the Pipeline was triggered.

# You have now configured automated build upon pushing to Git!
