PROJECT=$1
ENV=$2
oc new-project ${PROJECT:ml-dev}
oc adm policy add-scc-to-user anyuid -z default
oc secrets new-dockercfg push-secret --docker-server=172.30.1.1:5000 --docker-username=admin --docker-password=$(oc whoami -t) --docker-email=admin@example.com
oc secrets add serviceaccount/default secrets/push-secret --for=pull,mount
oc create -f slush-marklogic-node-templatel-${ENV:=dev}.yml
oc new-app slush-marklogic-node-app

