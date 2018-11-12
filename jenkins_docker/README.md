## Steps to get jenkins running as a container

### Configure credentials

- Update user and pass in `configure-credentials.groovy`

### Configure root URL

- Update rootUrl in `configure-root-url.groovy`

### Build docker image and push to docker hub

```bash
docker build -t your-namespace/jenkins .
docker login
docker push your-namespace/jenkins
```

### Running the container

```bash
docker run -p 8080:8080 -p 50000:50000 --name jenkins \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "JENKINS_OPTS=--prefix=/jenkins" \
    -d your-namespace/jenkins:latest
```