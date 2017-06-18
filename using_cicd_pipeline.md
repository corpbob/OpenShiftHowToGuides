# How to Use the CI/CD Pipeline in OpenShift Origin

## Assumptions:
- OpenShift origin is successfully installed.

## Create the DEV Environment

- Create a new project named todo-dev
- Click on Add To Project and search for mongodb. Select mongodb-persistent
- Configure mongodb settings. Set the following:
Database Service Name: mongodb
Database UserName: demo
Database Password: demo
Database Admin Password: demo
Database name: todo-api


<img src="images/cicd_mongodb_settings.png" height="400px">

- Click OK.

- Click on Add To Project and search for nodejs. Select the one at the left:

<img src="images/cicd_node_js.png" height=400px>

- Configure NodeJS settings. Set the name and git url:

```
Name: todo
Git URL: https://github.com/corpbob/todoAPIjs.git
```

<img src="images/cicd_nodejs_settings1.png" height=400px>



