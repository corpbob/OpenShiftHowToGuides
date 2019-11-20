# Using ConfigMaps 

For containers to be portable across environments, we can put configuration parameters in environment variables. However, most of the applications read their configurations from configuration files. For example, in the Java platform, we call these config files as properties files. 

In this section, we will learn how to externalize configuration files using ConfigMaps.

## Get the contents of /opt/gogs/custom/conf/app.ini
```
[root@openshift todoAPIjs]# oc get pods
NAME                 READY     STATUS    RESTARTS   AGE
gogs-3-t3wqs         1/1       Running   0          9h
postgresql-1-7969q   1/1       Running   0          10h
```
- Take note of the pod and get the contents of /opt/gogs/custom/conf/app.ini.

```
oc rsh gogs-3-t3wqs cat /opt/gogs/custom/conf/app.ini > app.ini.tmp
```

Since the generated file contains '\r' characters, let's get rid of that:

```
tr -d '\r' < app.ini.tmp > app.ini
```

## Create a config map 

In the same terminal window, import the file into a ConfigMap. In this example, we give it a name "gogs-config" but you can use any name as long at it is unique in the namespace/project. Execute the following command:

```
oc create configmap gogs-config --from-file=app.ini
```

Check the newly created ConfigMap:

```
oc get configmap gogs-config -o yaml
```
The following 2 commands are equivalent to the first one:

```
oc get configmap/gogs-config -o yaml
oc get cm/gogs-config -o yaml
```

We now need to mount this ConfigMap to the pod by setting it as a volume and mounting it at the directory /opt/gogs/custom/conf.

First, let us scale down the pods to 0:

```
oc scale dc/gogs --replicas=0
```

Next, set the ConfigMap as a volume in the DeploymentConfig:

```
 oc set volume dc/gogs --add --type=configmap --mount-path=/opt/gogs/custom/conf --configmap-name=gogs-config
```

Finally, redeploy the gogs container:

```
oc rollout latest dc/gogs
oc scale dc/gogs --replicas=1
```

Next Exercise: [Using Jenkins Pipeline](05_using_jenkins_pipeline.md)
