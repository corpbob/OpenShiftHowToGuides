# How To Install Openshift Origin 3 nodes using Ansible
## Pre-Requisites
- You should have added your hosts to DNS
- You have a wildcard dns entry

## Prepare Hosts
- Install base software

```
yum -y install wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct NetworkManager
```

- Update to the latest packages and reboot

```
yum update
systemctl reboot
```
- Install Atomic

```
yum -y install atomic
```
- Install docker

```
yum -y install docker-1.13.1
```
## Create the ansible hosts file in /root/hosts

```
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
containerized=true
openshift_deployment_type=origin
openshift_release=3.9
openshift_clock_enabled=true
my_domain=mydomain.com

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
openshift_master_default_subdomain=openshift.{{ my_domain }}

# Set the port of the master (default is 8443) if the master is a dedicated host
#openshift_master_api_port=443
#openshift_master_console_port=443

# default project node selector
osm_default_node_selector='env=dev'

# Router selector (optional)
openshift_hosted_router_selector='env=dev'
openshift_hosted_router_replicas=1

# Registry selector (optional)
openshift_registry_selector='env=dev'
# host group for masters
[masters]
master.mydomain.com

# host group for etcd
[etcd]
master.{{ my_domain }}

# host group for nodes, includes region info
[nodes]
master.{{ my_domain }} openshift_public_hostname="master.ellipticurve.com"  openshift_schedulable=true openshift_node_labels="{'name': 'master',  'env': 'dev'}" 
node2.{{ my_domain }} openshift_schedulable=true openshift_node_labels="{'name': 'node2',  'env': 'dev', 'region': 'infra' }"
node3.{{ my_domain }} openshift_schedulable=true openshift_node_labels="{'name': 'node3',  'env': 'dev'}"
```
## Run the pre-requisites

```
atomic install --system \
    --storage=ostree \
    --set INVENTORY_FILE=/root/hosts \
    --set PLAYBOOK_FILE=/usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml \
    --set OPTS="-vvv" \
    docker.io/openshift/origin-ansible:v3.9.28
```

## Run the installer

```
atomic install --system \
    --storage=ostree \
    --set INVENTORY_FILE=/root/hosts \
    --set PLAYBOOK_FILE=/usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml \
    --set OPTS="-vvv" \
    docker.io/openshift/origin-ansible:v3.9.28
```
