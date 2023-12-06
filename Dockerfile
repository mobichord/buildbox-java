# Use the Eclipse Temurin base image with Java
#FROM eclipse-temurin:17-jdk-alpine
FROM  azul/zulu-openjdk-alpine:17-jre-latest

# Set environment variables
ENV LANG C.UTF-8
ENV PYTHON_PIP_VERSION 20.2.3
ENV PYTHON_VERSION 3.8.5-r0
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /usr/local/go/bin:$PATH:$GOPATH/bin

# Install essential packages and remove the existing symlink for /bin/sh
RUN apk update && \
    apk add --no-cache \
        curl \
        wget \
        tar \
        bash \
        git \
        openssh-client \
        ca-certificates \
        python3 \
        openssl \
        xz \
        gcc \
        musl-dev \
        go && \
    rm /bin/sh && \
    ln -s /bin/bash /bin/sh

# Remove the existing /usr/bin/python (if it's not needed)
RUN rm -f /usr/bin/python

# Create a symbolic link for /usr/bin/python3 to /usr/bin/python
RUN ln -s /usr/bin/python3 /usr/bin/python


# Install Pip and Python packages
RUN wget -O /tmp/get-pip.py 'https://bootstrap.pypa.io/get-pip.py' && \
    python /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" && \
    pip install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" && \
    pip install boto3 argparse awscli && \
    rm /tmp/get-pip.py && \
    rm -rf ~/.cache

# Install Docker client
ARG DOCKER_CLI_VERSION_DOS="24.0.7"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION_DOS.tgz"
RUN mkdir -p /tmp/download && \
    curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download && \
    mv /tmp/download/docker/docker /usr/bin/docker && \
    chmod +x /usr/bin/docker && \
    rm -rf /tmp/download

# Install Maven
ARG MAVEN_VERSION=3.9.5
RUN mkdir -p /usr/share/maven /usr/share/maven/ref && \
    curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xzC /usr/share/maven --strip-components=1 && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# Set Maven environment variables
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/root/.m2"