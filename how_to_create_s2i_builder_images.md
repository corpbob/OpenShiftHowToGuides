# How to Build s2i images

In this HOWTO, we will create an s2i builder image for spring boot.

1. Download the s2i binary
```
curl -L https://github.com/openshift/source-to-image/releases/download/v1.1.10/source-to-image-v1.1.10-27f0729d-linux-amd64.tar.gz -o s2i.tar.gz
```
2. Clone the s2i project
```
cd $HOME
git clone https://github.com/openshift/source-to-image.git
```

3. Create a directory $HOME/tmp
```
mkdir $HOME/tmp
```
4. Copy the NginX example
```
cp -r $HOME/source-to-image/examples/nginx-centos7/ $HOME/tmp/my-spring-boot-s2i
```

5. Change directory to $HOME/tmp/my-spring-boot-s2i

6. Inside the directory are the following files:
```
Dockerfile
Makefile
README.md
s2i
test
```
6. Replace the contents of the Dockerfile with

```
# nginx-centos7
# Here you can use whatever base image is relevant for your application.
FROM centos:centos7

# Here you can specify the maintainer for the image that you're building
LABEL maintainer="Your Name <your.name@example.com>"

# Export an environment variable that provides information about the application version.
# Replace this with the version for your application.
ENV NGINX_VERSION=1.6.3

# Set the labels that are used for OpenShift to describe the builder image.
LABEL io.k8s.description="Nginx Webserver" \
    io.k8s.display-name="Nginx 1.6.3" \
    io.openshift.expose-services="8080:http" \
    io.openshift.tags="builder,webserver,html,nginx" \
    # this label tells s2i where to find its mandatory scripts
    # (run, assemble, save-artifacts)
    io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"

# Install the nginx web server package and clean the yum cache
#RUN yum install -y epel-release && \
#    yum install -y --setopt=tsflags=nodocs nginx && \
#    yum clean all
RUN yum install -y java-1.8.0-openjdk-devel maven && yum clean all

# Copy the S2I scripts to /usr/libexec/s2i since we set the label that way
COPY ./s2i/bin/ /usr/libexec/s2i

#RUN chown -R 1001:1001 /usr/share/nginx
#RUN chown -R 1001:1001 /var/log/nginx
#RUN chown -R 1001:1001 /var/lib/nginx
#RUN touch /run/nginx.pid
#RUN chown -R 1001:1001 /run/nginx.pid
#RUN chown -R 1001:1001 /etc/nginx

USER 1001

# Set the default port for applications built using this image
EXPOSE 8080

# Modify the usage script in your application dir to inform the user how to run
# this image.
CMD ["/usr/libexec/s2i/usage"]

```


