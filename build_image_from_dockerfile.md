# How to build a docker image from a Dockerfile in OpenShift

Suppose you have the followig Dockerfile:

```
#==== BEGIN DOCKER FILE
FROM centos:latest
RUN yum install -y java-1.8.0-openjdk-devel
RUN yum install -y unzip
RUN adduser tomcat
USER tomcat
RUN cd /home/tomcat && curl -L http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.zip -o apache-tomcat-9.0.8.zip
#COPY apache-tomcat-9.0.0.M19.zip /home/tomcat
RUN cd /home/tomcat && unzip apache-tomcat-9.0.8.zip  && chmod -R 777 /home/tomcat && ln -s apache-tomcat-9.0.8 tomcat
EXPOSE 8080
RUN cd /home/tomcat/tomcat/bin && chmod +x *.sh
ENTRYPOINT cd /home/tomcat/tomcat/bin && ./catalina.sh run
#==== END DOCKER FILE
```

1. Create a new project

```
oc new-project test
```

2. process the docker file

```
cat Dockerfile | oc new-build --to=mytomcat -D -
```

3. Using the web console, go to Builds->Builds->mytomcat->View Log. Wait for the build to finish.

4. Create a new app

```
oc new-app mytomcat
```

5. Create a route

```
oc expose mytomcat
```

6. Go to web and click on the route created for mytomcat.
