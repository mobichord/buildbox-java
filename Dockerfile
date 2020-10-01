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

ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"

ENV PYTHON_PIP_VERSION 20.2.3
ENV PYTHON_VERSION 3.8.5-r0

ARG DOCKER_CLI_VERSION="18.06.3-ce"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.tgz"

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

# # Install Python 2.7.13 (https://github.com/docker-library/python/blob/ad4706ad7d23ef13472d2ee340aa43f3b9573e3d/2.7/alpine/Dockerfile)
# RUN set -ex \
# 	&& apk add --no-cache --virtual .fetch-deps \
# 		gnupg \
# 		openssl \
# 		tar \
# 		xz \
# 	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
# 	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
# 	&& export GNUPGHOME="$(mktemp -d)" \
# 	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
# 	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
# 	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
# 	&& mkdir -p /usr/src/python \
# 	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
# 	&& rm python.tar.xz \
# 	&& apk add --no-cache --virtual .build-deps  \
# 		bzip2-dev \
# 		gcc \
# 		gdbm-dev \
# 		libc-dev \
# 		linux-headers \
# 		make \
# 		ncurses-dev \
# 		openssl \
# 		openssl-dev \
# 		pax-utils \
# 		readline-dev \
# 		sqlite-dev \
# 		tcl-dev \
# 		tk \
# 		tk-dev \
# 		zlib-dev \
# # add build deps before removing fetch deps in case there's overlap
# 	&& apk del .fetch-deps \
# 	&& cd /usr/src/python \
# 	&& ./configure \
# 		--enable-shared \
# 		--enable-unicode=ucs4 \
# 	&& make -j$(getconf _NPROCESSORS_ONLN) \
# 	&& make install \
# 	&& wget -O /tmp/get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
# 	&& python2 /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" \
# 	&& rm /tmp/get-pip.py \
# # we use "--force-reinstall" for the case where the version of pip we're trying to install is the same as the version bundled with Python
# # ("Requirement already up-to-date: pip==8.1.2 in /usr/local/lib/python3.6/site-packages")
# # https://github.com/docker-library/python/pull/143#issuecomment-241032683
# 	&& pip install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" \
# # then we use "pip list" to ensure we don't have more than one pip version installed
# # https://github.com/docker-library/python/pull/100
# 	&& [ "$(pip list |tac|tac| awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
# 	&& find /usr/local -depth \
# 		\( \
# 			\( -type d -a -name test -o -name tests \) \
# 			-o \
# 			\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
# 		\) -exec rm -rf '{}' + \
# 	&& runDeps="$( \
# 		scanelf --needed --nobanner --recursive /usr/local \
# 			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
# 			| sort -u \
# 			| xargs -r apk info --installed \
# 			| sort -u \
# 	)" \
# 	&& apk add --virtual .python-rundeps $runDeps \
# 	&& pip install boto3 argparse awscli \
# 	&& apk del .build-deps \
# 	&& rm -rf /usr/src/python ~/.cache
