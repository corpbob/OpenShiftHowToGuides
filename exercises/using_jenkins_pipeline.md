# Using Jenkins Pipeline

## Register to Gogs 

First we need to register to Gogs as a developer.

![Register To Gogs](images/register_to_gogs.png)

## Create a new Repository

Click the + sign of My Repositories. Set the following details:

- Repository Name = todoAPIjs
- Visibility = Private

Click Create Repository

![Repository Details](images/new_repository_details.png)

Copy the new repository url to the clipboard

![Repository URL](images/todo_repository.png)

## Import source code to the Repository

- Clone the application https://github.com/corpbob/todoAPIjs.git
```
git clone https://github.com/corpbob/todoAPIjs.git
```
- Add a new remote 
```
cd todoAPIjs
git remote add gogs <your gogs todoAPIjs repository url>
git push gogs master
```
You should be able to see something like this

![Todo After Import](images/todo_after_import.png)

## Create a new application using NodeJs template

Click "Add to Project", search for NodeJs

![New NodeJS Apps](images/new_app_nodejs.png)

Input the details as shown below. The project should be the project assigned to you.

![New NodeJs App Details](images/todo_nodejs_details.png)

Click on Create.

The build will fail in this case because the repository is private.

![Build Error](images/todo_error.png)
## Configure gogs secret in OpenShift
- Make sure you are in project todo-dev
```
oc project todo-dev
```

- Create basic secret by specifying your username and password to gogs. In the command below, substitute your gogs username and gogs password.
```
oc secrets new-basicauth  gogs-secret --username=<your gogs username> --password=<your gogs password>
```

