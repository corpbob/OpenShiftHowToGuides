# How To Install Openshift Origin 3 nodes using Ansible
## Pre-Requisites
- You should have added your hosts to DNS
- You have a wildcard dns entry

## Prepare Hosts
- Install base software

```
yum -y install wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
```

