# Using External Jenkins

## Assumptions
- You have an existing Jenkins installation that is hosted outside of OpenShift.
- You have read the [Using CICD Pipeline Part 2](using_cicd_pipeline_part2.md) and are interested to know how the same setup can be run using an external hosted jenkins.

## Install the Jenkins Pipeline Plugin
- Login as admin to jenkins
- Go to Manage Jenkins->Manage Plugins->Available
- Find "OpenShift Pipeline Jenkins Plugin"
- Install it.

## Create the Jenkins Service Account
- Make sure you're in the correct project

```
oc project todo-dev
```

- In your project create a service account named jenkins (if not existing already)
```
oc create sa jenkins
```

- Get the token name of Jenkins
```
[bobby@bcorpus2 ~]$ oc describe sa jenkins
Name:		jenkins
Namespace:	todo-dev
Labels:		<none>
Annotations:	<none>

Image pull secrets:	jenkins-dockercfg-97wdd

Mountable secrets: 	jenkins-token-wcccq
                   	jenkins-dockercfg-97wdd

Tokens:            	jenkins-token-vx9gj
                   	jenkins-token-wcccq

Events:	<none>
```
## Create a Jenkins Pipeline
- In Jenkins, create a new Item
- Give it a name "todo-pipeline"
- Click on "Pipeline" as shown below

![external_new_pipeline.png](images/external_new_pipeline.png)


