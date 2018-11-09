FROM jenkins/jenkins:lts

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY configure-credentials.groovy /usr/share/jenkins/ref/init.groovy.d/configure-credentials.groovy

COPY disable-cli.groovy /usr/share/jenkins/ref/init.groovy.d/disable-cli.groovy

COPY configure-root-url.groovy /usr/share/jenkins/ref/init.groovy.d/configure-root-url.groovy

COPY enable-csrf-protection.groovy /usr/share/jenkins/ref/init.groovy.d/enable-csrf-protection.groovy

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
    apt-get install -y docker-ce; \
    usermod -aG docker jenkins