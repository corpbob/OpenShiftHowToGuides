# Using ConfigMaps 

For containers to be portable across environments, we can put configuration paramaters in environment variables. However, most of the applications read their configurations from configuration files. For example, in the Java platform, we call these config files as properties files. 

In this section, we will learn how to externalize configuration files using ConfigMaps.

## Get the contents of /opt/gogs/custom/conf/app.ini
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
## Create a config map 

Got to Applications->Deployments->Gogs->Configuration. Click on Add Config Files.

![Add Config Files](images/add_config_files.png)

Since this is a new config map, we need to create it.

![Create Config Map](images/create_config_map.png)

 Create a config map with key "app.ini" and value equal to the contents of /opt/gogs/custom/conf/app.ini. This will redeploy the gogs application. TODO: Add detailed steps.
