# How to Setup Local Storage on OpenShift
## Assumptions
- You have an openshift cluster with N nodes.
- You can create loop back devices

## Create the disk image files, setup loop back devices, mount them, and change the SELinux context.

```
for i in `seq 0 49`
do
  dd if=/dev/zero of=/var/lib/origin/loop/loop$i.img bs=100M count=10
  losetup -fP /var/lib/origin/loop/loop$i.img
  mkfs.ext4 -F /var/lib/origin/loop/loop$i.img 
  mkdir -p /mnt/local-storage/loop/disk$i
  echo "/dev/loop$i     /mnt/local-storage/loop/disk$i  ext4 defaults 1 2" >> /etc/fstab
done

mount -a
chcon -R unconfined_u:object_r:svirt_sandbox_file_t:s0 /mnt/local-storage/
```

## Edit the /etc/origin/master/master-config.yaml and add enable the feature gates:

```
kubernetesMasterConfig:
  apiServerArguments:
    feature-gates:
    - PersistentLocalVolumes=true
    - VolumeScheduling=true
    :
  controllerArguments:
    :
    feature-gates:
    - PersistentLocalVolumes=true
    - VolumeScheduling=true
    
```

## Edit the /etc/origin/node/node-config.yaml and enable feature gates:

```
kubeletArguments: 
  :
  feature-gates:
  - PersistentLocalVolumes=true
  - VolumeScheduling=true
```

## Edit the /etc/origin/master/scheduler.json and add CheckVolumeBinding

```
{
    "apiVersion": "v1", 
    "kind": "Policy", 
    "predicates": [
        {
            "name": "CheckVolumeBinding"
        },
        :
     ]
 }
    

```

## Restart all the masters
```
systemctl restart origin-master-api origin-master-controllers
```

## Restart all the nodes

```
systemctl restart origin-node
```

## Create a Config map

```
kind: ConfigMap
metadata:
  name: local-volume-config
data:
    "local-loop": | 
      {
        "hostDir": "/mnt/local-storage/loop", 
        "mountDir": "/mnt/local-storage/loop" 
      }
```

## Create a project local-storage

```
oc new-project local-storage
```

## Create a service account and give it root privileges

```
oc create serviceaccount local-storage-admin
oc adm policy add-scc-to-user privileged -z local-storage-admin
```

## Install the template

```
oc create -f https://raw.githubusercontent.com/openshift/origin/master/examples/storage-examples/local-examples/local-storage-provisioner-template.yaml
```
