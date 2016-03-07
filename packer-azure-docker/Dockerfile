FROM debian:jessie

# Packer version
ENV PACKER_VERSION 0.8.6

# Updates + backports in order to get go version 1.5
RUN echo "deb http://http.debian.net/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list && apt-get update

# Packer
RUN apt-get install -y wget unzip
RUN mkdir /packer && cd /packer && wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && unzip packer_${PACKER_VERSION}_linux_amd64.zip && ln -s /packer/packer /usr/local/bin/

# Packer Azure
#RUN apt-get -t jessie-backports install -y golang=2:1.5.1-4~bpo8+1
#RUN GOPATH=/packer go get github.com/Azure/packer-azure/packer/plugin/...
RUN cd /packer && wget -q https://github.com/Azure/packer-azure/releases/download/prerelease/packer-azure-linux-amd64-prerelease.tar.gz && tar xvf packer-azure-linux-amd64-prerelease.tar.gz