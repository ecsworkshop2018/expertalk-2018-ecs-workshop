### Build docker image and push to docker hub

```bash
ECR_REPOSITORY_PATH="<<ECR_REPOSITORY_PATH>>"

source ~/workspace_config

JENKINS_TAG="${FIRST_NAME}-$(date +%s)"

$(aws ecr get-login --no-include-email --region us-east-1)

docker build \
    --build-arg "ROOT_URL=http://${FIRST_NAME}.ecsworkshop2018.online/jenkins" \
    --build-arg "USER_NAME=${JENKINS_USER_NAME}" \
    --build-arg "USER_PASS=${JENKINS_PASSWORD}" \
    --build-arg "FIRST_NAME=${FIRST_NAME}" \
    -t ${JENKINS_ECR_REPOSITORY_PATH}:${JENKINS_TAG} .

docker push ${ECR_REPOSITORY_PATH}:${JENKINS_TAG}
```

### Running the container

```bash
docker run -p 8080:8080 --name jenkins \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "JENKINS_OPTS=--prefix=/jenkins" \
    -d ${ECR_REPOSITORY_PATH}:${JENKINS_TAG}
```
