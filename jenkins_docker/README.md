## Steps to get jenkins running as a container

### Configure credentials

- Update user and pass in `configure-credentials.groovy`

### Configure root URL

- Update rootUrl in `configure-root-url.groovy`

### Build docker image and push to docker hub

```bash
docker build -t docker-hub-registry/jenkins .
docker login
docker push docker-hub-registry/jenkins
```

### Running the container

```bash
docker run -p 8080:8080 -p 50000:50000 --name jenkins -d docker-hub-registry/jenkins:latest
```