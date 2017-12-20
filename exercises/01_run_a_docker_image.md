# How to run a docker image in OpenShift

## Login into OpenShift 

*Important: Please substitute for "userX" the user id assigned to you*

```
oc login -u userX
```

## Create a new project

```
oc new-project userX-dev
```

## Run the app 

```
oc new-app bcorpusjr/tomcat
```

## Allow the public to access your application

```
oc expose svc tomcat
```

Next Exercise: [Adding a Database Using Templates](02_adding_a_database_using_templates.md)
