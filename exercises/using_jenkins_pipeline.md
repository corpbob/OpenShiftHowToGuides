# Using Jenkins Pipeline

## Import source code into Gogs

- Clone the application https://github.com/corpbob/todoAPIjs.git
```
git clone https://github.com/corpbob/todoAPIjs.git
```
- Login to gogs and create a new repository named todoAPIjs. Make it private.
- Add a new remote 
```
cd todoAPIjs
git remote add gogs <your gogs todoAPIjs repository url>
git push gogs master
```
## Configure gogs secret in OpenShift
- Make sure you are in project todo-dev
```
oc project todo-dev
```

- Create basic secret by specifying your username and password to gogs. In the command below, substitute your gogs username and gogs password.
```
oc secrets new-basicauth  gogs-secret --username=<your gogs username> --password=<your gogs password>
```

