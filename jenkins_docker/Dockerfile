FROM ecs-workshop/jenkins-base:lts

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

RUN mkdir -p /root/.ssh

COPY github_ssh_private_key /root/.ssh/id_rsa

RUN chmod 400 /root/.ssh/id_rsa

RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts

COPY init_scripts/* /usr/share/jenkins/ref/init.groovy.d/

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

RUN sed -i "s|SEED_JOB_REPO_URL|${SEED_JOB_REPO_URL}|g" /usr/share/jenkins/ref/init.groovy.d/create-seed-job.groovy
