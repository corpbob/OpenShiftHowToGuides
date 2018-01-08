# Using External Jenkins

## Assumptions
- You have an existing Jenkins installation that is hosted outside of OpenShift.
- You have read the [Using CICD Pipeline Part 2](using_cicd_pipeline_part2.md) and are interested to know how the same setup can be run using an external hosted jenkins.

## Install the Jenkins Pipeline Plugin
- Login as admin to jenkins
- Go to Manage Jenkins->Manage Plugins->Available
- Find "OpenShift Pipeline Jenkins Plugin"
- Install it.

## Create a Jenkins Pipeline
- In Jenkins, create a new Item
- Give it a name "todo-pipeline"
- Click on "Pipeline" as shown below

![external_new_pipeline.png](images/external_new_pipeline.png)
