FROM jenkins/jenkins:lts

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY configure-credentials.groovy /usr/share/jenkins/ref/init.groovy.d/configure-credentials.groovy

COPY disable-cli.groovy /usr/share/jenkins/ref/init.groovy.d/disable-cli.groovy

COPY configure-root-url.groovy /usr/share/jenkins/ref/init.groovy.d/configure-root-url.groovy

COPY enable-csrf-protection.groovy /usr/share/jenkins/ref/init.groovy.d/enable-csrf-protection.groovy

ARG ROOT_URL

RUN if [ -z "$ROOT_URL" ]; then echo "ERROR: ROOT_URL not set"; exit 1; fi

ARG USER_NAME

RUN if [ -z "$USER_NAME" ]; then echo "ERROR: USER_NAME not set"; exit 1; fi

ARG USER_PASS

RUN if [ -z "$USER_PASS" ]; then echo "ERROR: USER_PASS not set"; exit 1; fi

RUN sed -i "s|ROOT_URL|${ROOT_URL}|g" /usr/share/jenkins/ref/init.groovy.d/configure-root-url.groovy

RUN sed -i "s/USER_NAME/${USER_NAME}/g" /usr/share/jenkins/ref/init.groovy.d/configure-credentials.groovy

RUN sed -i "s/USER_PASS/${USER_PASS}/g" /usr/share/jenkins/ref/init.groovy.d/configure-credentials.groovy

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
    apt-get install -y docker-ce="18.06.1~ce~3-0~debian"; \
    usermod -aG docker jenkins