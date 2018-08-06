# How to Install OpenShift Origin in one node Using Ansible for Development Purposes

## Assumptions:

- CentOS operating System running as a VM in virtual box.
- Download CentOS from here: http://mirror.vodien.com/centos/7/isos/x86_64/CentOS-7-x86_64-Everything-1708.iso

## Create a Host-Only Network in VirtualBox
- Navigate to VirtualBox->Preferences

<img src="images/host-only1.png" height="200px">

- A dialog box will appear

<img src="images/host-only2.png" height="400px">

- Add a host-only network and set it's IP address to 10.1.2.1.

<img src="images/host-only3.png" height="400px">

- Click OK

## Install CentOS
- Using VirtualBox, click the Create button

<img src="images/install_centos_create.png" height="400px">

- specify the name. The version should be Red Hat (64-bit)
- Allocate at least 8 GB RAM, 4 CPU

<img src="images/install_centos_memory.png" height="400px">

<img src="images/install_centos_cpu.png" height="400px">

- Configure the Network. Set the first adapter to NAT

<img src="images/networking-nat.png" height="400px">

- Set the second adapter to the host-only network you created earlier

<img src="images/networking-host-only.png" height="400px">

## Configure CentOS

- Once installation is complete, configure the networking inside CentOS. As root edit the file /etc/sysconfig/network-scripts/ifcfg-enp0s3 and set it to these contents

```
TYPE=Ethernet
BOOTPROTO=dhcp
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
DEVICE=enp0s3
ONBOOT=yes
ZONE=public
```
- As root create a file /etc/sysconfig/network-scripts/ifcfg-enp0s8 and set it's contents to the below:

```
TYPE=Ethernet
BOOTPROTO=none
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s8
DEVICE=enp0s8
ONBOOT=yes
IPADDR=10.1.2.2
ZONE=public
```
- reboot the virtual machine to make sure the network settings work. After the reboot, test if you can ping yahoo.com:

```
[root@openshift sysconfig]# ping yahoo.com
PING yahoo.com (98.139.180.149) 56(84) bytes of data.
64 bytes from ir1.fp.vip.bf1.yahoo.com (98.139.180.149): icmp_seq=1 ttl=63 time=227 ms
64 bytes from ir1.fp.vip.bf1.yahoo.com (98.139.180.149): icmp_seq=2 ttl=63 time=228 ms
^C
--- yahoo.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 227.997/228.146/228.295/0.149 ms
```
- From the host machine, you should be able to ping the VM ip 10.1.2.2. Otherwise, wait awhile, at the VM's Power button, found at the upper right of the console, make sure that the 'Ethernet(enp0s8)' is connected. 

```
Red-Hats-MacBook-Pro:~ bcorpus$ ping 10.1.2.2
PING 10.1.2.2 (10.1.2.2): 56 data bytes
64 bytes from 10.1.2.2: icmp_seq=0 ttl=64 time=0.454 ms
^C
--- 10.1.2.2 ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.454/0.454/0.454/0.000 ms
```
## Install OpenShift 3.9
- copy the script below to a file named install_openshift.sh inside the directory /root
```
#### Filename: install_openshift.sh #####
HOSTNAME=10.1.2.2.nip.io
if [ ! -f ~/.updated ]
then
  hostnamectl set-hostname $HOSTNAME
  yum -y install wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct 
  yum update -y
  touch ~/.updated
  systemctl reboot   
fi

yum -y install     https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible pyOpenSSL
cd ~
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible/
git checkout release-3.9
yum install docker-1.13.1
systemctl start docker
yum install -y NetworkManager
systemctl start NetworkManager
yum install -y python-passlib
yum install -y java-1.8.0-openjdk-headless

cat << EOF> /etc/ansible/hosts
# Create an OSEv3 group that contains the master, nodes, etcd, and lb groups.
[OSEv3:children]
masters
etcd
nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
openshift_enable_docker_excluder=False
openshift_enable_openshift_excluder=False
ansible_ssh_user=root
ansible_become=true
#containerized=true
openshift_deployment_type=origin
openshift_release=3.9
openshift_clock_enabled=true
ansible_service_broker_install=false
openshift_enable_service_catalog=false
template_service_broker_install=false

openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/openshift-passwd'}]

# Create dev and admin users
openshift_master_htpasswd_users={'dev': '$apr1$LcfsxR41$zY2JK4Bg9gXeBDKXiokRZ1', 'admin': '$apr1$f4jGxBUp$TMIBlmIVoVf9PKHWoL4w8.'}

# apply updated node defaults
openshift_node_kubelet_args={'pods-per-core': ['10'], 'max-pods': ['250'], 'image-gc-high-threshold': ['80'], 'image-gc-low-threshold': ['60']}

osm_default_node_selector='env=dev'
openshift_hosted_metrics_deploy=true
openshift_metrics_image_version=v3.9
#openshift_hosted_logging_deploy=true

# Disable some pre-flight checks 
openshift_disable_check=memory_availability,disk_availability,package_version,docker_storage,docker_image_availability

# default subdomain to use for exposed routes
openshift_master_default_subdomain=$HOSTNAME

# Set the port of the master (default is 8443) if the master is a dedicated host
#openshift_master_api_port=443
#openshift_master_console_port=443

# default project node selector
osm_default_node_selector='env=dev'

# Router selector (optional)
openshift_hosted_router_replicas=1


# Registry selector (optional)
openshift_registry_selector='env=dev'
# host group for masters
[masters]
$HOSTNAME

# host group for etcd
[etcd]
$HOSTNAME

# host group for nodes, includes region info
[nodes]
$HOSTNAME openshift_public_hostname="$HOSTNAME"  openshift_schedulable=true openshift_node_labels="{'name': 'master',  'env': 'dev', 'region': 'infra'}" ansible_connection=local
EOF

ansible-playbook -i /etc/ansible/hosts  ~/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -i /etc/ansible/hosts  ~/openshift-ansible/playbooks/deploy_cluster.yml
### End script
```
- execute it using

```
bash install_openshift.sh
```

- Initially it will install some packages and update yum then reboot.
- After the reboot, run the script again.
```
bash install_openshift.sh
```

- A successful deployment should look like

```
Sunday 15 April 2018  23:02:41 -0400 (0:00:00.087)       0:14:21.113 ********** 
=============================================================================== 
openshift_master : restart master api ---------------------------------------------------------------------------------------------------------------- 33.47s
Run health checks (install) - EL --------------------------------------------------------------------------------------------------------------------- 19.42s
openshift_metrics : Create objects ------------------------------------------------------------------------------------------------------------------- 18.95s
openshift_hosted : Ensure OpenShift pod correctly rolls out (best-effort today) ---------------------------------------------------------------------- 16.95s
openshift_hosted : Ensure OpenShift pod correctly rolls out (best-effort today) ---------------------------------------------------------------------- 16.47s
openshift_service_catalog : oc_process --------------------------------------------------------------------------------------------------------------- 14.34s
openshift_service_catalog : wait for api server to be ready ------------------------------------------------------------------------------------------ 12.97s
openshift_hosted_facts : Set hosted facts ------------------------------------------------------------------------------------------------------------ 11.49s
openshift_hosted_facts : Set hosted facts ------------------------------------------------------------------------------------------------------------ 11.27s
openshift_sanitize_inventory : pause ----------------------------------------------------------------------------------------------------------------- 10.08s
openshift_master : restart master controllers --------------------------------------------------------------------------------------------------------- 8.31s
openshift_metrics : Generating serviceaccounts for hawkular metrics/cassandra ------------------------------------------------------------------------- 7.20s
openshift_hosted_facts : Set hosted facts ------------------------------------------------------------------------------------------------------------- 7.05s
openshift_metrics : slurp ----------------------------------------------------------------------------------------------------------------------------- 7.01s
openshift_metrics : Applying /tmp/openshift-metrics-ansible-8zfzlh/templates/metrics-hawkular-cassandra-svc.yaml -------------------------------------- 6.91s
restart master api ------------------------------------------------------------------------------------------------------------------------------------ 6.78s
openshift_service_catalog : Create api service -------------------------------------------------------------------------------------------------------- 6.70s
openshift_hosted_facts : Set hosted facts ------------------------------------------------------------------------------------------------------------- 6.53s
openshift_metrics : Set serviceaccounts for hawkular metrics/cassandra -------------------------------------------------------------------------------- 5.98s
openshift_metrics : Start Heapster -------------------------------------------------------------------------------------------------------------------- 5.53s
```
- Login as system:admin
```
oc login -u system:admin
```

- Add admin user to admin role so that all projects will be visible in the web console.

```
oc adm policy add-cluster-role-to-user cluster-admin admin
```
- Login as admin. Password is admin

```
oc login -u admin
```

- Navigate to the web console at https://10.1.2.2:8443 and login with the credentials

```
username: admin
password: admin
```
You should be able to see this:

<img src="images/openshift_ansible.png">

# Configure host directories persistent volume

- Execute the command below to create persistent volumes in the directory /var/lib/origin/openshift.local.pv

```
for i in `seq 0 100`
do
  mkdir -p /var/lib/origin/openshift.local.pv/pv$i
  chcon -u system_u -r object_r -t svirt_sandbox_file_t -l s0 /var/lib/origin/openshift.local.pv/pv$i
  chmod 777 /var/lib/origin/openshift.local.pv/pv$i
done
```

- Create the PV objects in OpenShift

```
for i in `seq 0 100`
do
cat << EOF | oc create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    volume: pv$i
  name: pv$i
spec:
  accessModes:
  - ReadWriteOnce
  - ReadWriteMany
  - ReadOnlyMany
  capacity:
    storage: 100Gi
  hostPath:
    path: /var/lib/origin/openshift.local.pv/pv$i
  persistentVolumeReclaimPolicy: Recycle
EOF
done
```

# Congratulations! OpenShift Origin is up and running!
