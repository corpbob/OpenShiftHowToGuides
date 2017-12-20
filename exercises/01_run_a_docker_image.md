# How to run a docker image in OpenShift

## Login into OpenShift 

*Important: Please substitute for "openshift-devel" the user id assigned to you*

```
oc login -u openshift-devel
```

## Create a new project

```
oc new-project myproject
```

## Run the app 

```
oc new-app bcorpusjr/tomcat
```

## Allow the public to access your application

```
oc expose svc tomcat
```


