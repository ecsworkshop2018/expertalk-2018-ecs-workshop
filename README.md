# expertalk-2018-ecs-workshop
Repository for ecs workshop for expert talk india conference 2018.

## Pre workshop setup step

#### You need following things installed on your machine

- Git
- Git bash (for windows only)
- Github account (with SSH key configured)
- Virtualbox
(Vagrant can support VirtualBox version 4.0.x, 4.1.x, 4.2.x, 4.3.x, 5.0.x, 5.1.x, and 5.2.x. Other versions are unsupported and you will get an error message. Please note that beta and pre-release versions of VirtualBox are not supported and may not be well-behaved.)
Install with the help of the official installer. https://www.virtualbox.org/wiki/Downloads

- Vagrant (2.2.2)
Do not use a package manager for installing Vagrant. Please use the official installer. https://www.vagrantup.com/downloads.html

- IntelliJ Idea or Eclipse (or any other IDE you are comfortable with)

#### Pull the vagrant box in an empty directory with the following command

Note: Run all commands on Terminal or GitBash (not GitCMD)

```bash
mkdir ecsworkshop
cd ecsworkshop
mkdir basevm
cd basevm
vagrant init prashantkalkar/ecsworkshopbox --box-version 1.0.1
vagrant up
```

#### Test the box is working

Get into vagrant vm.
```bash
vagrant ssh
```
Check docker is working

```bash
vagrant ➜  docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 2
Server Version: 18.06.1-ce
...
```
Check images
```bash
vagrant ➜  docker images
REPOSITORY                                  TAG                 IMAGE ID            CREATED             SIZE
kaushikchandrashekar/ecs-workshop-jenkins   v1.0                2a93fab2fcdc        9 days ago          1.6GB
jenkins/jenkins                             lts                 d7c5abfe8477        4 weeks ago         703MB
```
Check terraform version
```bash
vagrant ➜  terraform -version
Terraform v0.11.10
```
Check java setup
```bash
vagrant ➜  echo $JAVA_HOME
/usr/lib/jvm/java-8-openjdk-amd64/
```
check whether dos2unix is installed

```bash
vagrant ➜  which dos2unix
/usr/bin/dos2unix
```

## Setup steps during workshop

*Note: Just follow these steps. Its ok even if you do not understand everything. We are going to cover these during the workshop*

### Fork ecsworkshop repositories

Fork following repositories to your github user

https://github.com/ecsworkshop2018/expertalk-2018-ecs-workshop <br />
https://github.com/ecsworkshop2018/seed_job <br />
https://github.com/ecsworkshop2018/odin

### Clone repositories

Open terminal or git bash (**on host machine not VM**)

```bash
➜  cd ecsworkshop/
➜  git clone git@github.com:prashant-ee/expertalk-2018-ecs-workshop.git
Cloning into 'expertalk-2018-ecs-workshop'...
```

### Download aws access key details (required to configure AWS cli later).

Login to AWS account (we are going to provide access to AWS during workshop). Reset password for first time. 

Create a new AWS accessKey and download **accessKeys.csv** to your user home directory. 

### Create GitHub Personal access token (required to create github webhooks on jenkins).

Use following link to setup a personal GitHub access token.

https://support.cloudbees.com/hc/en-us/articles/234710368-GitHub-User-Scopes-and-Organization-Permission

Select **repo** and **admin:repo_hook** for the token scope.
Note the toekn down somewhere as it will not be available again. This is required in the setup below. 

### Setup workspace config

Go to workspace config template and copy it to user home directory.

```bash
➜  cd ecsworkshop/
➜  cd expertalk-2018-ecs-workshop/
➜  cd docker_dev_vagrant/
➜  cp workspace_config.template ~/workspace_config
```
Open ~/workspace_config in any text editor of your choise. Add required information and save the file.

```
FIRST_NAME="<your first name>"
JENKINS_USER_NAME="<your jenkins user name>"
JENKINS_PASSWORD="<your jenkins password>"
GITHUB_USER_NAME="<your github user name>"
GITHUB_USER_EMAIL="<your github user email>"
GITHUB_ACCESS_TOKEN="<your github personal access token>"
SEED_JOB_REPO_URL="<your seed job repo url>"
```
Details:

FIRST_NAME - make sure this is unique, prefer to put the AWS username for this. <br />
JENKINS_USER_NAME - Choose a name of your Jenkins admin (every participant will have his own Jenkins). <br />
JENKINS_PASSWORD - Choose a password for your Jenkins admin user.  <br />
GITHUB_USER_NAME - Put in your github user name (git information is used to configure git during workshop) <br />
GITHUB_USER_EMAIL - Put in your github email. <br />
GITHUB_ACCESS_TOKEN - Put in the personal access token we created earlier. <br />
SEED_JOB_REPO_URL - Put in the https github url of the seed job (the one we forked earlier). <br />

### Build Development box (VM) which are going to use during workshop

```bash
➜  cd ecsworkshop/
➜  cd expertalk-2018-ecs-workshop/
➜  cd docker_dev_vagrant/
➜  vagrant up
➜  vagrant ssh
```

## Setup your jenkins

### Build your jenkins image

```console
vagrant ➜  cd repos/expertalk-2018-ecs-workshop/jenkins_docker/
vagrant ➜  JENKINS_TAG="${FIRST_NAME}-$(date +%s)"
vagrant ➜  cp ~/.ssh/id_rsa ./github_ssh_private_key
vagrant ➜  docker build \
    --build-arg "ROOT_URL=https://${FIRST_NAME}-jenkins.ecsworkshop2018.online" \
    --build-arg "JENKINS_USER_NAME=${JENKINS_USER_NAME}" \
    --build-arg "JENKINS_PASSWORD=${JENKINS_PASSWORD}" \
    --build-arg "GITHUB_USER_NAME=${GITHUB_USER_NAME}" \
    --build-arg "GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL}" \
    --build-arg "GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN}" \
    --build-arg "SEED_JOB_REPO_URL=${SEED_JOB_REPO_URL}" \
    -t ${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG} .
    ...
vagrant ➜ rm ./github_ssh_private_key
```

### Push jenkins image to ECR in AWS account

```console
vagrant ➜  $(aws ecr get-login --no-include-email --region us-east-1)
vagrant ➜  docker push ${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG}
```

### Provision Jenkins infrastructure and deploy jenkins

#### Update Jenkins image (the one we just build) in terraform tfvars

```console
vagrant ➜  PREVIOUS_JENKINS_IMAGE_CONFIG=$(cat ../terraform/jenkins/terraform.tfvars | grep jenkins_docker_image)
vagrant ➜  NEW_JENKINS_IMAGE_CONFIG="jenkins_docker_image=\"${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG}\""
vagrant ➜  sed -i "s|${PREVIOUS_JENKINS_IMAGE_CONFIG}|${NEW_JENKINS_IMAGE_CONFIG}|g" ../terraform/jenkins/terraform.tfvars
```

#### Update user name in terraform tfvars (to seperate your jenkins instance from others)

```console
vagrant ➜  PREVIOUS_UNIQUE_ID=$(cat ../terraform/jenkins/terraform.tfvars | grep unique_identifier)
vagrant ➜  NEW_UNIQUE_ID="unique_identifier=\"${FIRST_NAME}\""
vagrant ➜  sed -i "s|${PREVIOUS_UNIQUE_ID}|${NEW_UNIQUE_ID}|g" ../terraform/jenkins/terraform.tfvars
```

### Update terraform with your unique name

open `expertalk-2018-ecs-workshop` as project in your IDE.
open file `expertalk-2018-ecs-workshop/terraform/jenkins/main.tf`
Put in your unique name (possibly same as your AWS username) at the place of **${unique}** in the following code:

```HCL
backend "s3" {
    bucket         = "ecs-workshop-terraform-state-jenkins"
    key            = "${unique}-jenkins.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "Terraform-Lock-Table"
  }
```

### Prepare jenkins python virtual environment

This is required because terraform uses a python script and requires certain dependencies to be available. Setting the virtual environment will setup those dependencies

```console
vagrant ➜  cd expertalk-2018-ecs-workshop
vagrant ➜  cd terraform/jenkins
vagrant ➜  virtualenv venv
vagrant ➜  source venv/bin/activate
(venv) vagrant ➜  pip install -r requirements.txt
```

### Provision the jenkins using terraform


```console
(venv) vagrant ➜  pwd
/home/vagrant/repos/expertalk-2018-ecs-workshop/terraform/jenkins
(venv) vagrant ➜  terraform init
Initializing modules...
...
```
```console
(venv) vagrant ➜  terraform plan -out tf_plan
Acquiring state lock. This may take a few moments...
Refreshing Terraform state in-memory prior to plan...
...
```
```console
(venv) vagrant ➜  terraform apply tf_plan
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
Acquiring state lock. This may take a few moments...
aws_iam_role.jenkins_instance_ec2: Creating...
...
```

### Access jenkins

Now your jenkins should be available at (it might take some time) :

https://{your-unique-name}-jenkins.ecsworkshop2018.online/

### Provide Jenkins access to push to your repository

```console
(venv) vagrant ➜  cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJX3+f6QNMfJ87hoomn2j+593dJP0LxNLOyqVCOGg0cZ0HGZkFiXeA2ElnnBtJn4zqw5kL0ANTlRk3nCiW8qF63HWlbRX9+LioRxDL/j33+ajkn3jfxOBFvXDmXSMNY/qxsKVRnkp588FSiW4ODgbYp6c4vtP+VxojgeBIEX56oYqMRd7+6hgEYdyBcFD7oW/509QfXvV9q9RhkOV7jkMxbodsf9qHXvYSOTNW9VOe7XWk95qvaHrrbJIUTLKhFCZxKIDvrpy4a5NtTk2RDvgGwoafpdT3gW/fJU4Qbg43Hum7um/OS0xRGxBswfvlTWOyrR2jkprjbT36ONHW+oGPVMrC3l...
...
y+SGYaE1svLPl7yYBA1o8i9rgkrelefOxMI/wdvxxxYNm7zvFi/DOaXCL4VD7G4L+HHVEQJupgkxGpKAirnQ== youremail@provider.com
```
Copy the entire content of the ssh public key and add it to your github account.
Follow steps from here (from step 2):
https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

## Overview of the Example - Asgard portal

Our application name is *Asgard*. Its provides details about the Asgard gods. Currently Odin and Thor. 
Since we are using microservices architecture we have seperate services for the Odin and thor. 

## Exercises

### Exercise 0 - Containerize Odin service.

We will
- Run Odin service locally. 
- Add docker file for the odin service.
- Run the docker file locally to test it.
- Create a jenkins build to create Odin service's docker image and push to ECR. 
- This pipeline will run for every commit of the Odin's service.

### Exercise 1 - Infrastructure for Asgard services - Single instance cluster

Refer: https://github.com/ecsworkshop2018/asgard-infrastructure/blob/master/exercise1/README.md

### Exercise 2 - Infrastructure for Asgard services - Single instance ASG cluster

Refer: https://github.com/ecsworkshop2018/asgard-infrastructure/blob/master/exercise2/README.md

### Exercise 3 - Infrastructure for Asgard services - Route53 + ALB (load balancer) + ASG + cluster.

Refer: https://github.com/ecsworkshop2018/asgard-infrastructure/blob/master/exercise3/README.md

### Exercise 4 - Deploy Odin service to Asgard application cluster

Refer: https://github.com/ecsworkshop2018/odin-infrastructure/blob/master/README.md

### Exercise 5 - Deploy Thor service to Asgard cluster

Execute the terraform/Jenkins job to deploy service thor. 

### Exercise 6 - Adaptive cluster with mapped services

There exists a platform through which clusters and its services can be provisioned.

We will
- Create a mapping for a cluster with no services.
- Provision Asgard cluster using the platform.
- Add Odin service on the cluster.
- Add another service (Thor) to the cluster.
- Update Odin docker image and redeploy on the cluster. 
- Move Thor to Midgard (Earth) cluster.

