Assumption:
1. There is a user called openshift-dev with the following credentials:
username: openshift-dev
password: devel

2. Create a docker image using the following Dockerfile:

$ cat Dockerfile
FROM centos:latest
RUN yum install -y java-1.8.0-openjdk-devel
RUN yum install -y unzip
RUN adduser tomcat
USER tomcat
RUN cd /home/tomcat && curl http://mirror.rise.ph/apache/tomcat/tomcat-9/v9.0.0.M21/bin/apache-tomcat-9.0.0.M21.zip -o apache-tomcat-9.0.0.M21.zip
#COPY apache-tomcat-9.0.0.M19.zip /home/tomcat
RUN cd /home/tomcat && unzip apache-tomcat-9.0.0.M21.zip && ln -s apache-tomcat-9.0.0.M21 tomcat
EXPOSE 8080
RUN cd /home/tomcat/tomcat/bin && chmod +x *.sh
ENTRYPOINT cd /home/tomcat/tomcat/bin && ./catalina.sh run

Build a docker image
```bash
$ docker build -t myproject/tomcat
```

Login as openshift-dev

oc login -u openshift-dev -p devel

Create a new project. In this example, we call this project "myproject".

[vagrant@rhel-cdk master]$ oc new-project myproject
Now using project "myproject" on server "https://10.1.2.2:8443".

You can add applications to this project with the 'new-app' command. For example, try:

    oc new-app centos/ruby-22-centos7~https://github.com/openshift/ruby-ex.git

to build a new example application in Ruby.


[vagrant@rhel-cdk master]$ docker tag myproject/tomcat hub.openshift.rhel-cdk.10.1.2.2.xip.io/bobbytest/tomcat
[vagrant@rhel-cdk master]$ docker images|less
[vagrant@rhel-cdk master]$ docker push hub.openshift.rhel-cdk.10.1.2.2.xip.io/bobbytest/tomcat
The push refers to a repository [hub.openshift.rhel-cdk.10.1.2.2.xip.io/bobbytest/tomcat]
a682f6ed0658: Pushed 
b481041927bf: Pushed 
ee434c86fe87: Pushed 
93bc0aef485b: Pushed 
9bffbd5a8942: Pushed 
f82048aca1ad: Pushed 
36018b5e9787: Pushed 
latest: digest: sha256:05f929a0deee05b2000ad3bae60e5db478577e2a18264745464e21b7f4a45efb size: 7424
