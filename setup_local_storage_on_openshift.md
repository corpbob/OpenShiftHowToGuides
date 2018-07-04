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

## Create a Config map. Name it config.yaml.

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
## Import this into OpenShift
```
oc create -f config.yaml
``

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
## Create the app

```
oc new-app -p CONFIGMAP=local-volume-config \
  -p SERVICE_ACCOUNT=local-storage-admin \
  -p NAMESPACE=local-storage \
  -p PROVISIONER_IMAGE=quay.io/external_storage/local-volume-provisioner:v1.0.1 \
  local-storage-provisioner
```

## Create the storage class yaml storage.yaml
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
 name: local-loop
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

## import this yaml 
```
oc create -f storage.yaml
```
## Make this the default storage class by patching the storage class object.

```
oc patch storageclass local-loop -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## You should be able to see the persistent volumes created by the provisioner

```
oc get pv

NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
local-pv-108b59fd   923928Ki   RWO            Delete           Available             local-loop               17h
local-pv-1097a6b3   923928Ki   RWO            Delete           Available             local-loop               17h
local-pv-1608a587   923928Ki   RWO            Delete           Available             local-loop               17h
local-pv-172068c5   923928Ki   RWO            Delete           Available             local-loop               17h
local-pv-17e07158   923928Ki   RWO            Delete           Available             local-loop               17h

```

## Congratulations! You can now deploy persistent pods using the local storage volume.
