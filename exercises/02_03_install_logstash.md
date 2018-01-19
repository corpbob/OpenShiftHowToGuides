# Install LogStash

```
oc new-app docker.elastic.co/logstash/logstash:6.1.2
```

## Add storage to LogStash

- Go to Applications->Deployments->Logstash
- Click on Configuration->Add Storage
- Click on create storage

![create_log_stash_storage.png](images/create_log_stash_storage.png)

- Set the following parameters
  - Name: logstash
  - Access Mode: RWO
  - Size: 1 GiB
- Click on Create


![create_log_stash_storage_2.png](images/create_log_stash_storage_2.png)





