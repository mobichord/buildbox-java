FROM openjdk:15-jdk-alpine

ENV PATH /usr/local/bin:$PATH

ENV LANG C.UTF-8

ENV PYTHON_PIP_VERSION 20.2.3
ENV PYTHON_VERSION 3.8.5-r0

RUN set -ex \
	&& apk add --no-cache \
		curl wget tar bash git openssh-client ca-certificates \
		python3 openssl tar xz \
		gcc musl-dev openssl go \
	&& ln -s /usr/bin/python3 /usr/bin/python \
	&& wget -O /tmp/get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
	&& python /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" \
	&& rm /tmp/get-pip.py \
	&& pip install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" \
	&& apk add --virtual .python-pkg-deps \
	&& pip install boto3 argparse awscli \
	&& apk del .python-pkg-deps \
	&& rm -rf ~/.cache

# Configure Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /usr/local/go/bin:$PATH
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

ARG MAVEN_VERSION=3.9.5
ARG USER_HOME_DIR="/root"

ENV PYTHON_PIP_VERSION 20.2.3
ENV PYTHON_VERSION 3.8.5-r0

#ARG DOCKER_CLI_VERSION="18.06.3-ce"
ARG DOCKER_CLI_VERSION_DOS="24.0.7"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION_DOS.tgz"

# Install Docker client
RUN set -ex \
	&& mkdir -p /tmp/download \
	&& curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download \
	&& mv /tmp/download/docker/docker /usr/bin/docker \
	&& chmod +x /usr/bin/docker \
    && rm -rf /tmp/download

# Install maven
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    | tar -xzC /usr/share/maven --strip-components=1 \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"