# Install RabbitMQ
## Run the rabbit mq docker image

```
oc new-app luiscoms/openshift-rabbitmq:3
```

## Get the pod name of rabbitmq

```
oc get pods
```

to get

```
NAME                         READY     STATUS    RESTARTS   AGE
elasticsearch-3-jmzss        1/1       Running   0          2h
kibana-2-k7htt               1/1       Running   0          12m
logstash-2-d9548             1/1       Running   0          3h
openshift-rabbitmq-1-9mcrp   1/1       Running   0          1m
redis-1-gxpfm                1/1       Running   0          3h
```

## Using commandline to get the logs
```
oc logs -f openshift-rabbitmq-1-9mcrp
```

## You should be able to get something like this:

```
=INFO REPORT==== 19-Jan-2018::06:57:14 ===
started TCP Listener on [::]:5672
 completed with 0 plugins.
=INFO REPORT==== 19-Jan-2018::06:57:14 ===
Server startup complete; 0 plugins started.
```

*Reference: https://github.com/luiscoms/openshift-rabbitmq*
