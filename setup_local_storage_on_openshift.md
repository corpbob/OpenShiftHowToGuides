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

## Edit the /etc/origin/master/master-config.yml and add enable the feature gates:

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

## 
