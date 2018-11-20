### Set login for ECR repository
```bash
$(aws ecr get-login --no-include-email --region us-east-1)
```

### Build docker image
```bash
JENKINS_TAG="${FIRST_NAME}-$(date +%s)"

cp ~/.ssh/id_rsa ./github_ssh_private_key

docker build \
    --build-arg "ROOT_URL=https://${FIRST_NAME}-jenkins.ecsworkshop2018.online" \
    --build-arg "JENKINS_USER_NAME=${JENKINS_USER_NAME}" \
    --build-arg "JENKINS_PASSWORD=${JENKINS_PASSWORD}" \
    --build-arg "GITHUB_USER_NAME=${GITHUB_USER_NAME}" \
    --build-arg "GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL}" \
    --build-arg "GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN}" \
    --build-arg "SEED_JOB_REPO_URL=${SEED_JOB_REPO_URL}" \
    -t ${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG} .

rm ./github_ssh_private_key
```

### Running the container locally

Stop and remove container if created previously, then run jenkins

```bash
docker rm -f jenkins; docker run -p 8080:8080 --name jenkins \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -d ${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG}
```
Jenkins is now running at: http://localhost:8080

### Push Jenkins image to ECR (build the image first).

```bash
docker push ${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG}
```

### Update Jenkins image as terraform variable.

```bash
PREVIOUS_JENKINS_IMAGE_CONFIG=$(cat ../terraform/jenkins/terraform.tfvars | grep jenkins_docker_image)

NEW_JENKINS_IMAGE_CONFIG="jenkins_docker_image=\"${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG}\""

sed -i "s|${PREVIOUS_JENKINS_IMAGE_CONFIG}|${NEW_JENKINS_IMAGE_CONFIG}|g" ../terraform/jenkins/terraform.tfvars
```
```

### Update user first name as terraform variable.

```bash
PREVIOUS_USER_FIRST_NAME=$(cat ../terraform/jenkins/terraform.tfvars | grep user_first_name)

NEW_USER_FIRST_NAME="user_first_name=\"${FIRST_NAME}\""

sed -i "s|${PREVIOUS_USER_FIRST_NAME}|${NEW_USER_FIRST_NAME}|g" ../terraform/jenkins/terraform.tfvars
```
