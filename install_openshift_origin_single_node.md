# How to Install OpenShift Origin in one node for Development Purposes

## Assumptions:

- CentOS operating System running as a VM in virtual box.
- Download CentOS from here: http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Everything-1611.iso

## Create a Host-Only Network in VirtualBox
- Navigate to VirtualBox->Preferences

<img src="images/host-only1.png" height="200px">

- A dialog box will appear

<img src="images/host-only2.png" height="200px">

- Add a host-only network and set it's IP address to 10.1.2.1.

<img src="images/host-only3.png" height="200px">

- Click OK

## Install CentOS
- Using VirtualBox, click the Create button

<img src="images/install_centos_create.png" height="200px">

- specify the name. The version should be Red Hat (64-bit)
- Allocate at least 8 GB RAM, 4 CPU

<img src="images/install_centos_memory.png" height="200px">

<img src="images/install_centos_cpu.png" height="200px">

- Configure the Network. Set the first adapter to NAT

<img src="images/networking-nat.png" height="200px">

- Set the second adapter to the host-only network you created earlier

<img src="images/networking-host-only.png" height="200px">

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
- From the host machine, you should be able to ping the VM ip 10.1.2.2

```
Red-Hats-MacBook-Pro:~ bcorpus$ ping 10.1.2.2
PING 10.1.2.2 (10.1.2.2): 56 data bytes
64 bytes from 10.1.2.2: icmp_seq=0 ttl=64 time=0.454 ms
^C
--- 10.1.2.2 ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.454/0.454/0.454/0.000 ms
```
## Install oc client

```bash
curl -L https://github.com/openshift/origin/releases/download/v1.5.1/openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz -o oc.tar.gz
tar tzf oc.tar.gz 
mv openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit/oc /usr/local/bin/
```

## Install docker

```
yum install -y docker
```
- Edit the file /etc/sysconfig/docker and add the line 

```
INSECURE_REGISTRY='--insecure-registry 172.30.0.0/16'
```
- restart docker

```
systemctl restart docker
```
## Configure firewalld

- Run the command below and get the IP

```
[root@openshift sysconfig]# docker network inspect -f "{{range .IPAM.Config }}{{ .Subnet }}{{end}}" bridge
172.17.0.0/16
```

- Use the IP return above for the below commands:

```
firewall-cmd --permanent --new-zone dockerc
firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
firewall-cmd --permanent --zone dockerc --add-port 53/udp
firewall-cmd --permanent --zone dockerc --add-port 8053/udp
firewall-cmd --reload
```
- Run the addtional commands below to open the ports from outside the VM

```
firewall-cmd --permanent --zone public --add-port 8443/tcp
firewall-cmd --permanent --zone public --add-port 80/tcp
firewall-cmd --permanent --zone public --add-port 443/tcp
firewall-cmd --reload
 ```

## Install OpenShift

- Create directory /var/lib/origin/openshift.local.data to hold etcd data.

```
mkdir /var/lib/origin/openshift.local.data
```

```
oc cluster up --public-hostname=10.1.2.2 --routing-suffix=10.1.2.2.xip.io --host-data-dir=/var/lib/origin/openshift.local.data --use-existing-config=true
```
