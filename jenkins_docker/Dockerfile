FROM jenkins/jenkins:lts

USER root

RUN apt-get update; \
    apt-get install -y apt-transport-https \
                       ca-certificates \
                       curl \
                       gnupg2 \
                       software-properties-common \
                       lsb-release

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt-get update;\
    apt-get install -y docker-ce="18.06.1~ce~3-0~debian"

# install maven
RUN apt-get install -y maven

# Install pip
RUN apt-get install -y python3-pip

# install aws cli
RUN pip3 install awscli

# install aws cli
RUN pip3 install virtualenv

# Install JQ and YQ
RUN apt-get install -y jq
RUN pip3 install yq

# install terraform
RUN cd /tmp; \
    wget --show-progress https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip; \
    unzip -d /usr/local/bin terraform_0.11.10_linux_amd64.zip

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

RUN mkdir -p /root/.ssh

COPY github_ssh_private_key /root/.ssh/id_rsa

RUN chmod 400 /root/.ssh/id_rsa

RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY init_scripts/* /usr/share/jenkins/ref/init.groovy.d/

COPY seed-job-creator.groovy /seed-job-creator.groovy

ARG ROOT_URL

RUN if [ -z "$ROOT_URL" ]; then echo "ERROR: ROOT_URL not set"; exit 1; fi

ARG JENKINS_USER_NAME

RUN if [ -z "$JENKINS_USER_NAME" ]; then echo "ERROR: JENKINS_USER_NAME not set"; exit 1; fi

ARG JENKINS_PASSWORD

RUN if [ -z "$JENKINS_PASSWORD" ]; then echo "ERROR: JENKINS_PASSWORD not set"; exit 1; fi

ARG GITHUB_USER_EMAIL

RUN if [ -z "$GITHUB_USER_EMAIL" ]; then echo "ERROR: GITHUB_USER_EMAIL not set"; exit 1; fi

ARG GITHUB_USER_NAME

RUN if [ -z "$GITHUB_USER_NAME" ]; then echo "ERROR: GITHUB_USER_NAME not set"; exit 1; fi

ARG GITHUB_ACCESS_TOKEN

RUN if [ -z "$GITHUB_ACCESS_TOKEN" ]; then echo "ERROR: GITHUB_ACCESS_TOKEN not set"; exit 1; fi

ARG SEED_JOB_REPO_URL

RUN if [ -z "$SEED_JOB_REPO_URL" ]; then echo "ERROR: SEED_JOB_REPO_URL not set"; exit 1; fi

RUN sed -i "s|ROOT_URL|${ROOT_URL}|g" /usr/share/jenkins/ref/init.groovy.d/configure-root-url.groovy

RUN sed -i "s/JENKINS_USER_NAME/${JENKINS_USER_NAME}/g" /usr/share/jenkins/ref/init.groovy.d/configure-credentials.groovy

RUN sed -i "s/JENKINS_PASSWORD/${JENKINS_PASSWORD}/g" /usr/share/jenkins/ref/init.groovy.d/configure-credentials.groovy

RUN sed -i "s/JENKINS_USER_NAME/${JENKINS_USER_NAME}/g" /usr/share/jenkins/ref/init.groovy.d/configure-access-control-strategy-for-builds.groovy

RUN sed -i "s/GITHUB_USER_EMAIL/${GITHUB_USER_EMAIL}/g" /usr/share/jenkins/ref/init.groovy.d/configure-git-global-config.groovy

RUN sed -i "s/GITHUB_USER_NAME/${GITHUB_USER_NAME}/g" /usr/share/jenkins/ref/init.groovy.d/configure-git-global-config.groovy

RUN sed -i "s/GITHUB_USER_NAME/${GITHUB_USER_NAME}/g" /usr/share/jenkins/ref/init.groovy.d/configure-github-credentials.groovy

RUN sed -i "s/GITHUB_ACCESS_TOKEN/${GITHUB_ACCESS_TOKEN}/g" /usr/share/jenkins/ref/init.groovy.d/configure-github-credentials.groovy

RUN sed -i "s|SEED_JOB_REPO_URL|${SEED_JOB_REPO_URL}|g" /seed-job-creator.groovy
