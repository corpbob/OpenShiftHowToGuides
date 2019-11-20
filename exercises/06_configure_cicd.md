# Configure the CI/CD pipeline
## Setup the UAT environment
### Create a project for UAT. 

*Important! Use the correct value of userX*

```
oc new-project userX-uat
```

### Give the "jenkins" service account the ability to invoke deployments in the UAT environment

*Important! Use the correct value of userX*

oc policy add-role-to-user edit system:serviceaccount:userX-dev:jenkins -n userX-uat 

### Give the default service account access to images in DEV environment

Important: in the command below, change the namespace "dev1-uat" to your uat project name and "dev1" to your dev project name.

*Important! Use the correct value of userX*

```
oc policy add-role-to-user system:image-puller system:serviceaccount:userX-uat:default --namespace=userX-dev
```

### Import the following templates

- Using a notepad or vi, create a file named uat.yaml and paste the below contents to this file and save.
- Ensure you are in the uat project by checking what project you are in using the command


*Important! Use the correct value of userX*

```
apiVersion: v1
kind: Template
metadata:
  creationTimestamp: null
  name: uat
objects:
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    labels:
      app: mongodb-persistent
      template: mongodb-persistent-template
    name: mongodb
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 1Gi
- apiVersion: v1
  kind: ImageStream
  metadata:
    labels:
      app: todo
    name: todo
  spec:
    lookupPolicy:
      local: false
    tags:
    - annotations: null
      from:
        kind: DockerImage
        name: 172.30.1.1:5000/${DEV_NAMESPACE}/todo:latest
      generation: null
      importPolicy: {}
      name: latest
      referencePolicy:
        type: ""
- apiVersion: v1
  data:
    database-admin-password: ZGVtbw==
    database-name: dG9kby1hcGk=
    database-password: ZGVtbw==
    database-user: ZGVtbw==
  kind: Secret
  metadata:
    annotations:
      template.openshift.io/expose-admin_password: '{.data[''database-admin-password'']}'
      template.openshift.io/expose-database_name: '{.data[''database-name'']}'
      template.openshift.io/expose-password: '{.data[''database-password'']}'
      template.openshift.io/expose-username: '{.data[''database-user'']}'
    labels:
      app: mongodb-persistent
      template: mongodb-persistent-template
    name: mongodb
  type: Opaque
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: mongodb-persistent
      template: mongodb-persistent-template
    name: mongodb
  spec:
    replicas: 1
    selector:
      name: mongodb
    strategy:
      activeDeadlineSeconds: 21600
      recreateParams:
        timeoutSeconds: 600
      resources: {}
      type: Recreate
    template:
      metadata:
        creationTimestamp: null
        labels:
          name: mongodb
      spec:
        containers:
        - env:
          - name: MONGODB_USER
            valueFrom:
              secretKeyRef:
                key: database-user
                name: mongodb
          - name: MONGODB_PASSWORD
            valueFrom:
              secretKeyRef:
                key: database-password
                name: mongodb
          - name: MONGODB_ADMIN_PASSWORD
            valueFrom:
              secretKeyRef:
                key: database-admin-password
                name: mongodb
          - name: MONGODB_DATABASE
            valueFrom:
              secretKeyRef:
                key: database-name
                name: mongodb
          image: centos/mongodb-32-centos7@sha256:a8186548488e545a7384913a3ea0503a4427b92cf17def2b5f60037180576b7c
          imagePullPolicy: IfNotPresent
          livenessProbe:
            failureThreshold: 3
            initialDelaySeconds: 30
            periodSeconds: 10
            successThreshold: 1
            tcpSocket:
              port: 27017
            timeoutSeconds: 1
          name: mongodb
          ports:
          - containerPort: 27017
            protocol: TCP
          readinessProbe:
            exec:
              command:
              - /bin/sh
              - -i
              - -c
              - mongo 127.0.0.1:27017/$MONGODB_DATABASE -u $MONGODB_USER -p $MONGODB_PASSWORD
                --eval="quit()"
            failureThreshold: 3
            initialDelaySeconds: 3
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          resources:
            limits:
              memory: 512Mi
          securityContext:
            capabilities: {}
            privileged: false
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          volumeMounts:
          - mountPath: /var/lib/mongodb/data
            name: mongodb-data
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
        volumes:
        - name: mongodb-data
          persistentVolumeClaim:
            claimName: mongodb
    test: false
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - mongodb
        from:
          kind: ImageStreamTag
          name: mongodb:3.2
          namespace: openshift
      type: ImageChange
    - type: ConfigChange
- apiVersion: v1
  kind: DeploymentConfig
  metadata:
    labels:
      app: todo
    name: todo
  spec:
    replicas: 1
    selector:
      deploymentconfig: todo
    strategy:
      activeDeadlineSeconds: 21600
      resources: {}
      rollingParams:
        intervalSeconds: 1
        maxSurge: 25%
        maxUnavailable: 25%
        timeoutSeconds: 600
        updatePeriodSeconds: 1
      type: Rolling
    template:
      metadata:
        creationTimestamp: null
        labels:
          app: todo
          deploymentconfig: todo
      spec:
        containers:
        - env:
          - name: PORT
            value: "8080"
          image: 172.30.1.1:5000/${DEV_NAMESPACE}/todo
          imagePullPolicy: Always
          name: todo
          ports:
          - containerPort: 8080
            protocol: TCP
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
    test: false
    triggers:
    - imageChangeParams:
        automatic: true
        containerNames:
        - todo
        from:
          kind: ImageStreamTag
          name: todo:TestReady
          namespace: ${DEV_NAMESPACE}
      type: ImageChange
    - type: ConfigChange
- apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: mongodb-persistent
      template: mongodb-persistent-template
    name: mongodb
  spec:
    ports:
    - name: mongo
      port: 27017
      protocol: TCP
      targetPort: 27017
    selector:
      name: mongodb
    sessionAffinity: None
    type: ClusterIP
- apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: todo
    name: todo
  spec:
    ports:
    - name: 8080-tcp
      port: 8080
      protocol: TCP
      targetPort: 8080
    selector:
      deploymentconfig: todo
    sessionAffinity: None
    type: ClusterIP
parameters:
- description: The name of the DEV namespace
  displayName: Dev Namespace
  name: DEV_NAMESPACE
  required: true
  value: user0-dev
```  
> The yaml above was generated using the command:
> oc export pvc,is,secret,dc,svc --as-template=uat > uat.yml
> and removing the sections like status, creationTimestamp, runtime annotations, generation, and those objects we don't want to create like jenkins related objects

- Ensure you are in the uat project by checking the output of the command below:

```
oc project
```

- Import the template 

```
oc create -f uat.yaml
```
This will give an output similar to:

```
template "uat" created
```

- Create a new application based on the template. **Make sure you substitute the correct value of X**

```
oc new-app uat -p DEV_NAMESPACE=userX-dev
```
This will give an output similar to 

```
--> Deploying template "dev2-uat/uat" to project dev2-uat

--> Creating resources ...
    persistentvolumeclaim "mongodb" created
    imagestream "todo" created
    secret "mongodb" created
    deploymentconfig "mongodb" created
    deploymentconfig "todo" created
    service "mongodb" created
    service "todo" created
--> Success
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose svc/mongodb' 
     'oc expose svc/todo' 
    Run 'oc status' to view your app.
```
- Expose the todo app to the public

```
oc expose svc todo
```

![Todo UAT Overview](images/todo_uat_overview_4.2.png)

## Configure the GitHook

- Login to Jenkins as your user id.
- Click on your UserId at the upper right hand corner.
- Click on Configure at the left hand navigation bar.
- In the API Token section, click on "Add new token". Give it a name and click Generate. Take note of the "User ID" and "API Token".
- Go to gogs page. Access the todoAPIjs repository -> Settings -> Git Hooks -> Post Receive. Paste the following script after substituting the user id and api token you got from Jenkins. The url should also be correct. 

*Instructor will show how to get the correct URL.*

```
#!/bin/bash
USERID=<your jenkins userid>
TOKEN=<your jenkins token>
JENKINS_URL=<your jenkins url>
while read oldrev newrev ref
do
    if [[ $ref =~ refs/tags ]];
    then
        echo "Master ref received.  Deploying master branch to production..."
        TAG=`echo $ref|sed 's#refs/tags/\(.*\)#\1#g'`
        curl -v -k --user $USERID:$TOKEN -G "$JENKINS_URL/buildWithParameters" -d token=secret -d commit=$newrev -d tag=$TAG
    else
        echo "Ref $ref successfully received.  Doing nothing: only the master branch may be deployed on this server."
    fi
done
```

## Configure Jenkins

- Login to Jenkins
- Click on todo-pipeline
- Click on Configure
- Tick "This Project is Parametrized"
- Add the following string parameters
  - tag
  - commit
- Tick "Trigger Builds Remotely". Set the token to "secret" (without the quotes).
- Click Save
- Modify the pipeline script

```
node('nodejs') {
  stage('build') {
    openshift.withCluster(){
      openshift.withProject(){
        sh """oc patch bc todo -p '{ "spec": { "source": { "git":  { "ref": \"${params.tag}\" }}}}'"""
        def bc= openshift.selector("bc/todo")
        bc.startBuild()
        bc.logs("-f")
      }
      
    }
    
  }

  stage('deploy') {
    //automatic deployment
  } 

  stage( 'Wait for approval')
  input( 'Aprove to production?')
  stage('Deploy UAT'){
    openshift.withCluster(){
      openshift.withProject() {
        openshift.tag( 'user0-dev/todo:latest', 'user0-dev/todo:TestReady')
      }
    }
  }
}
```

## Test the Setup

### Configure git email and username

- Execute the following commands to make sure git does not complain when you commit changes.

```
git config user.email "you@example.com"
git config user.name "Your Name"
```

### Change something

- Edit views/index.ejs. Make changes like putting a string "This is a test" near the title.
- Execute the following commands:
```
git add views/index.ejs
git commit -m "test"
git tag TestReady-1.0
git push gogs TestReady-1.0
```
- After the push, you should be able to see something like this:

```
Counting objects: 7, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 354 bytes | 0 bytes/s, done.
Total 4 (delta 2), reused 0 (delta 0)
remote: Master ref received.  Deploying master branch to production...
remote:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
remote:                                  Dload  Upload   Total   Spent    Left  Speed
remote:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0* About to connect() to jenkins-dev1.xxx.xxx.xxx.xxx.nip.io port 443 (#0)
remote: *   Trying xxx.xxx.xxx.xxx...
remote: * Connected to jenkins-dev1.xxx.xxx.xxx.xxx.nip.io (xxx.xxx.xxx.xxx) port 443 (#0)
remote: * Initializing NSS with certpath: sql:/etc/pki/nssdb
remote: * skipping SSL peer certificate verification
remote: * SSL connection using TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
remote: * Server certificate:
remote: * 	subject: CN=*.xxx.xxx.xxx.xxx.nip.io
remote: * 	start date: Dec 19 05:45:18 2017 GMT
remote: * 	expire date: Dec 19 05:45:19 2019 GMT
remote: * 	common name: *.xxx.xxx.xxx.xxx.nip.io
remote: * 	issuer: CN=openshift-signer@1513662256
remote: * Server auth using Basic with user 'openshift-dev-admin'
remote: > GET /job/dev1/job/dev1-todo-pipeline/buildWithParameters?token=secret&commit=13311ffd0bb1138d8db492aa5ae9remote: 7cc9&tag=TestReady-1.0 HTTP/1.1
remote: > Authorization: Basic b3BlbnNoaWZ0LWRldi1hZG1pbjpmZjM1ZmU2ZjQ3OTdmY2FjODMwMDgzMDkzMTRkNTc3Nw==
remote: > User-Agent: curl/7.29.0
remote: > Host: jenkins-dev1.xxx.xxx.xxx.xxx.nip.io
remote: > Accept: */*
remote: > 
remote: < HTTP/1.1 302 Found
remote: < Date: Wed, 20 Dec 2017 02:19:44 GMT
remote: < X-Content-Type-Options: nosniff
remote: < Location: https://jenkins-dev1.xxx.xxx.xxx.xxx.nip.io/job/dev1/job/dev1-todo-pipeline/
remote: < Content-Length: 0
remote: < Server: Jetty(9.4.z-SNAPSHOT)
remote: < Set-Cookie: f077bdd19e4769cc805d9c6fd3a63378=8825485b85ce65f504fc2e27c05ddbc6; path=/; HttpOnly; Secure
remote: < 
remote:   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
remote: * Connection #0 to host jenkins-dev1.xxx.xxx.xxx.xxx.nip.io left intact
To http://gogs-dev1.xxx.xxx.xxx.xxx.nip.io/corpbob/todoAPIjs.git
 * [new tag]         TestReady-1.0 -> TestReady-1.0
```
### Observe the Pipeline Run

- Got to the dev environment and click on Builds->Pipelines. You should be able to see a new pipeline being started.

![Pipeline Triggered](images/todo_dev_githook_trigger_pipeline_4.2.png)


- Go to the Overview page of your dev environment, scroll to "todo" and observe the application being redeployed.

![Todo Dev Redeploy](images/todo_dev_triggered_deploy_4.2_v2.png) 

- After a while, the deployment will pause and will ask for input to proceed. 

![Wait for Approval](images/todo_dev_wait_for_approval_4.2.png)

- Click on Input Required to open the Jenkins page and approve the request.

- Go to your UAT environment and watch "todo" being re-deployed.

![Deployment to UAT](images/todo_uat_deployment_4.2_v3.png)

- Open the URL of todo in UAT and check that your changes are there.

![Check Changes](images/todo_web_page_after_pipeline.png)

## If you got this far, Congratulations!

