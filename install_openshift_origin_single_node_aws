# How to Install OpenShift Origin in one node for Development Purposes

## Assumptions:

- You have an AWS account
- You launched an instance using CentOS 7 (x86_64) - with Updates HVM
- You have allocated an elastic IP, which we call <elastic-ip> moving forward
- You have associated <elastic-ip> to your running instance.

## Add the following entry to the security group

<img src="images/aws_security_group_openshift.png">

```
## Install oc client

```bash
curl -L https://github.com/openshift/origin/releases/download/v1.5.1/openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz -o oc.tar.gz
tar -xzvf oc.tar.gz 
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
- Edit the file /etc/docker/daemon.json and add the line 

```
{
 "other-prop": 'blah',
 "insecure-registries" : ["172.30.0.0/16"]
}
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
firewall-cmd --permanent --zone public --add-port 10250/tcp
firewall-cmd --reload
 ```

## Install OpenShift

- Create directory /var/lib/origin/openshift.local.data to hold etcd data.

```
sudo mkdir -p /var/lib/origin/openshift.local.data
```

```
[root@openshift sysconfig]# oc cluster up \
--public-hostname=10.1.2.2 --routing-suffix=10.1.2.2.nip.io \
--host-data-dir=/var/lib/origin/openshift.local.data \
--metrics=true
```
- You will get an output similar to the below

```
-- Checking OpenShift client ... OK
-- Checking Docker client ... OK
-- Checking Docker version ... OK
-- Checking for existing OpenShift container ... 
   Deleted existing OpenShift container
-- Checking for openshift/origin:v1.5.1 image ... OK
-- Checking Docker daemon configuration ... OK
-- Checking for available ports ... OK
-- Checking type of volume mount ... 
   Using nsenter mounter for OpenShift volumes
-- Creating host directories ... OK
-- Finding server IP ... 
   Using 10.0.2.15 as the server IP
-- Starting OpenShift container ... 
   Creating initial OpenShift configuration
   Starting OpenShift using container 'origin'
   Waiting for API server to start listening
   OpenShift server started
-- Adding default OAuthClient redirect URIs ... OK
-- Installing registry ... OK
-- Installing router ... OK
-- Installing metrics ... OK
-- Importing image streams ... OK
-- Importing templates ... OK
-- Login to server ... OK
-- Creating initial project "myproject" ... OK
-- Removing temporary directory ... OK
-- Checking container networking ... OK
-- Server Information ... 
   OpenShift server started.
   The server is accessible via web console at:
       https://10.1.2.2:8443

   The metrics service is available at:
       https://metrics-openshift-infra.10.1.2.2.xip.io

   You are logged in as:
       User:     developer
       Password: developer

   To login as administrator:
       oc login -u system:admin
```

- Add admin user to admin role so that all projects will be visible in the web console.

```
oc adm policy add-cluster-role-to-user admin admin
```

- Navigate to the web console at https://10.1.2.2:8443 and login with the credentials

```
username: admin
password: admin
```
You should be able to see this:

<img src="images/web_console.png">

# Congratulations! OpenShift Origin is up and running!
