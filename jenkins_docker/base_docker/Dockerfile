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

RUN apt-get install -y zip

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt