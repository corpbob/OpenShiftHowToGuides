# Running your own Git Service 
## Run the Go Git Service image using the command below

```
oc new-app wkulhanek/gogs:11.4
```

## Attach storage to gogs and mount to /data

We are going to replace the "non-persistent" volume mounted on /data and change it to a persistent volume. Go to Search>DeploymentConfig>gogs.  Scroll down to volumes and delete the volume mounted on /data.

![Delete Gogs Non-Persistent Volume](images/delete_gogs_volume_4.2.png)

Next we create a Persistent Volume Claim (PVC) that we will mount into "/data". Go to Search->PersistentVolumeClaim. Click on Create Persistent Volume Claim.

![Gogs Storage Details](images/gogs_storage_details_4.2.png)

Name it "gogs-storage", Single User Access Mode, and Size = 1Gi. Click Create.

Mount gogs-storage to /data and click Save.

![Create New Storage](images/add_gogs_storage2_4.2.png)

# Expose the gogs service 

Now we need to expose this service to the public. So we need a URL for this. Type the following command to create a route for the gogs service.

```
oc expose svc gogs
```

## Configure the gogs database by accessing the gogs url. TODO: Add detailed steps.

Go to Search->Route. Click on the gogs url to open the gogs service.

![Gogs Install Page](images/gogs_install_page.png)

Set the following parameters to the following values:
- Database Type = Postgresql
- Host = postgresql:5432
- User = gogs
- Password = gogs
- Database Name = gogs
- Run User = gogs

Set the application url to the url of gogs.

Click on Install Gogs. You will get the following page

![Gogs Sign-In Page](images/gogs_sign_in_page.png)

In the next exercise, we will learn how to externalize configuration using ConfigMaps

Next Exercise: [Using ConfigMaps](04_using_config_maps.md)
