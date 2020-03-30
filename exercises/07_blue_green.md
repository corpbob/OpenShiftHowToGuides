# Configure Blue-Green Deployment
## Create deployment configs for blue and green 
***In the following yaml files, substitute user0 with your username***

### Create a file todo-blue.yaml

```
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  labels:
    app: todo-blue
  name: todo-blue
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    deploymentconfig: todo-blue
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
      annotations:
        openshift.io/generated-by: OpenShiftNewApp
      creationTimestamp: null
      labels:
        app: todo-blue
        deploymentconfig: todo-blue
    spec:
      containers:
      - env:
        - name: PORT
          value: "8080"
        image: ' '
        imagePullPolicy: Always
        name: todo-blue
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
      - todo-blue
      from:
        kind: ImageStreamTag
        name: todo:blue
        namespace: user0-dev
    type: ImageChange
  - type: ConfigChange
```

### Create a file todo-green.yaml

```
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  labels:
    app: todo-green
  name: todo-green
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    deploymentconfig: todo-green
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
      annotations:
        openshift.io/generated-by: OpenShiftNewApp
      creationTimestamp: null
      labels:
        app: todo-green
        deploymentconfig: todo-green
    spec:
      containers:
      - env:
        - name: PORT
          value: "8080"
        image: ' '
        imagePullPolicy: Always
        name: todo-green
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
      - todo-green
      from:
        kind: ImageStreamTag
        name: todo:green
        namespace: user0-dev
    type: ImageChange
  - type: ConfigChange
```
### Create a file todo-blue-svc.yaml

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: todo-blue
  name: todo-blue
spec:
  ports:
  - name: 8080-tcp
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    deploymentconfig: todo-blue
  sessionAffinity: None
  type: ClusterIP
```

### Create a file todo-green-svc.yaml

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: todo-green
  name: todo-green
spec:
  ports:
  - name: 8080-tcp
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    deploymentconfig: todo-green
  sessionAffinity: None
  type: ClusterIP
```
### Import these configurations to OKD

```
oc create -f todo-blue-svc.yaml  
oc create -f todo-green-svc.yaml
oc create -f todo-blue.yaml  
oc create -f todo-green.yaml
```

### Change the route "todo" to point to service "todo-blue". Click on "Split traffic .." and pick the service "todo-green". Use the slider to 100% todo-blue. Since there are no pods for todo-blue. The URL will initially not work.

### Replace the pipeline script with the following:

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
      openshift.withProject('user0-uat') {
        service_name = openshift.selector('route',"todo").object().spec.to.name
        w1=openshift.selector('route',"todo").object().spec.to.weight
        //assume that that value is either 100 or 0
        if(w1 == 100){
            service_name = openshift.selector('route',"todo").object().spec.to.name
        } else {
            service_name = openshift.selector('route',"todo").object().spec.alternateBackends[0].name
        }
        print(service_name)
        if( service_name == 'todo-blue'){
            openshift.tag( 'user0-dev/todo:latest', 'user0-dev/todo:green')
        } else {
            openshift.tag( 'user0-dev/todo:latest', 'user0-dev/todo:blue')
        }
      }
    }
  }
}
```

### Test the setup by editing the index.ejs file and triggering the pipeline

### This will deploy the todo-green service. Edit the route to be 100% todo-green.

### Use the curl command to get the index page and confirm that your change is there.

### Optionally you can repeat the process. 
- Edit the index.ejs and trigger a pipeline build.
- This will then deploy the image to the service todo-blue
- The route will still be pointing to todo-green.
- Edit the route to point to todo-blue
- Using curl, check that the changes are there.


