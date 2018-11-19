### Set login for ECR repository
```bash
$(aws ecr get-login --no-include-email --region us-east-1)
```

### Build docker image
```bash

JENKINS_TAG="${FIRST_NAME}-$(date +%s)"

docker build \
    --build-arg "ROOT_URL=http://${FIRST_NAME}.ecsworkshop2018.online/jenkins" \
    --build-arg "USER_NAME=${JENKINS_USER_NAME}" \
    --build-arg "USER_PASS=${JENKINS_PASSWORD}" \
    --build-arg "FIRST_NAME=${FIRST_NAME}" \
    -t ${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG} .
```

### Running the container locally

Stop and remove container if created previously

```bash
docker rm -f jenkins
```

```bash
docker run -p 8080:8080 --name jenkins \
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
