# Install Elastic Search

## First set max_map_count in Linux

```
sudo sysctl -w vm.max_map_count=262144
```
*Note* The instructor should have done this already.

## Install elastic search

```
oc new-app docker.elastic.co/elasticsearch/elasticsearch:6.1.2
```
