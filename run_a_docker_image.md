# How to run a docker image in OpenShift

## Login into OpenShift 

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


