# Adding a Database Using Templates
## Browse the catalog and look for PostgreSQL database

![Service Catalog](images/service_catalog.png)
## Set the following required input fields to 'gogs'
- PostgreSQL Connection Username
- PostgreSQL Connection Password
- PostgreSQL Database Name

![Setting Database Parameters](images/gogs_database_settings.png)
## Click on Create. 
This will create the PostgreSQL database container and run it. It will also request for a persistent volume where it can persist the data across restarts.

```
[root@bcorpus2 exercise1]# oc get pvc
NAME         STATUS    VOLUME    CAPACITY   ACCESSMODES   STORAGECLASS   AGE
postgresql   Bound     pv0073    100Gi      RWO,ROX,RWX                  58s
```
