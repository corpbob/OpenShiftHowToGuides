
```
oc new-project bg
```

```
oc new-app https://github.com/corpbob/blue-green-demo.git -l app=blue --name=blue COLOR=blue PORT=8080
```

```
oc new-app https://github.com/corpbob/blue-green-demo.git -l app=green --name=green COLOR=green PORT=8080
```
```
oc expose svc green
```

```
[root@openshift ~]# oc get route
NAME      HOST/PORT                  PATH      SERVICES   PORT       TERMINATION   WILDCARD
green     green-bg.10.1.2.2.nip.io             blue       8080-tcp                 None
```

```
[root@openshift ~]# curl http://green-bg.10.1.2.2.nip.io/hello
green
```
```
oc patch route/green -p '{"spec":{ "to": { "name": "blue" }}}'
```

```
[root@openshift ~]# curl http://green-bg.10.1.2.2.nip.io/hello
blue
```
