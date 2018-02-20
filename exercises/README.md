# OpenShift Workshop

## Contents
- [How to run a docker image in OpenShift](01_run_a_docker_image.md)
The image that you created earlier will be run inside OpenShift to take advantage of Self-Healing, High Availability, and Auto-scaling.
- [Adding a Database Using Templates](02_adding_a_database_using_templates.md)
Will introduce you to the concept of templates. In particular, you will be adding a database using a template. This database will be used by Gogs Git Service.
- [Running your own Git Service](03_running_your_own_git_service.md)
We will be installing our individual git service that will be used in CI/CD.
- [Using ConfigMaps](04_using_config_maps.md)
Configuration is the difference between environments and should not be baked into the container image but rather externalized. This exercise will introduce you to externalizing configuration using environment variables and ConfigMaps.
- [Using Jenkins Pipeline](05_using_jenkins_pipeline.md)
Continuous Integration/Continuous Deployment and Containerization enables rapid deployment from Development to Production with minimal risk and rapid-rollback. We will use the built-in Jenkins pipeline of OpenShift to trigger the build of our application.
- [Configure the CI/CD pipeline](06_configure_cicd.md)
We will configure an end-to-end pipeline starting from a code pushed to the Git until it deploys to a higher environment with approvals in between. This demonstrates the ease at which containerization has make deployments rapid and can be done in business hours.

