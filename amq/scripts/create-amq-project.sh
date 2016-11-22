oc new-project amq-demo
oc policy add-role-to-user view system:serviceaccount:amq-demo:amq-service-account
oc create -n amq-demo -f amq-app-secret.json
oc create -n amq-demo -f amq62-persistent-ssl.json
