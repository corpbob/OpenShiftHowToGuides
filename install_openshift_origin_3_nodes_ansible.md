# How To Install Openshift Origin 3 nodes using Ansible
## Pre-Requisites
- You should have added your hosts to DNS
- You have a wildcard dns entry
- You have one master and 2 compute nodes
- IP addresses:
  - master : 10.1.2.2
  - node1  : 10.1.2.3
  - node2  : 10.1.2.4
- Your /etc/hosts has the following entries (in all nodes)

```
cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.1.2.2 master
10.1.2.3 node1
10.1.2.4 node2

```

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
- Install ansible

```
yum -y install     https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible pyOpenSSL
   
```
- Generate SSH keys

```
ssh-keygen 
ssh-copy-id -i ~/.ssh/id_rsa 10.1.2.3
ssh-copy-id -i ~/.ssh/id_rsa 10.1.2.4
```

- Install openshift-ansible

```
cd ~
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
git checkout release-3.11
```

- Install docker

```
yum -y install docker-1.13.1
```
## Create the ansible hosts file in /root/hosts

```
# Create an OSEv3 group that contains the masters, nodes, and etcd groups
[OSEv3:children]
masters
nodes
etcd
new_nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=root

# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true
os_firewall_use_firewalld=True
openshift_deployment_type=origin

# uncomment the following to enable htpasswd authentication; defaults to DenyAllPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

openshift_disable_check=memory_availability,disk_availability,package_version,docker_image_availability,package_availability,package_update,docker_storage
openshift_master_default_subdomain=apps.10.1.2.2.nip.io

# true by default
# openshift_cluster_monitoring_operator_install=false
# false by default
# openshift_metrics_install_metrics=true
# false by default
# openshift_logging_install_logging=true
# true by default
# openshift_enable_service_catalog=false
# false by default
# ansible_service_broker_install=false
# true by default
# template_service_broker_install=false
# true by default
# openshift_web_console_install=false
# true by default
# openshift_console_install=false
# preview only
# openshift_enable_olm=true
# host group for masters
[masters]
master openshift_ip=10.1.2.2 etcd_ip=10.1.2.2

# host group for etcd
[etcd]
master openshift_public_ip=10.1.2.2 etcd_ip=10.1.2.2

# host group for nodes, includes region info
[nodes]
master openshift_public_ip=10.1.2.2 etcd_ip=10.1.2.2 openshift_public_hostname=master.10.1.2.2.nip.io openshift_node_group_name='node-config-master-infra' openshift_schedulable=true ansible_connection=local
node1 openshift_public_ip=10.1.2.3 openshift_node_group_name='node-config-compute' openshift_schedulable=true 
node2 openshift_public_ip=10.1.2.4 openshift_node_group_name='node-config-compute' openshift_schedulable=true
```
## Run the pre-requisites

```
cd ~/openshift-ansible
ansible-playbook -i /root/hosts playbooks/prerequisites.yml
```

## Run the installer

```
cd ~/openshift-ansible
ansible-playbook -i /root/hosts playbooks/deploy_cluster.yml
```
