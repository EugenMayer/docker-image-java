FROM alpine:3.6

# build parameters
ENV JAVA_DISTRIBUTION=server-jre
ENV JAVA_MAJOR_VERSION=8
ENV JAVA_UPDATE_VERSION=152
ENV JAVA_BUILD_NUMBER=16
ENV JAVA_HASH=aa0333dd3019491ca4f6ddbe78cdb6d0

ENV GLIBC_VERSION=2.26-r0

ENV LANG en_US.UTF-8
ENV JAVA_VERSION=1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}
ENV JAVA_HOME=/opt/java/${JAVA_DISTRIBUTION}${JAVA_VERSION}
ENV JRE_HOME=/opt/java/${JAVA_DISTRIBUTION}${JAVA_VERSION}/jre
ENV JAVA_DOWNLOAD_URL=http://download.oracle.com/otn-pub/java/jdk/"${JAVA_MAJOR_VERSION}"u"${JAVA_UPDATE_VERSION}"-b"${JAVA_BUILD_NUMBER}"/${JAVA_HASH}/"${JAVA_DISTRIBUTION}"-"${JAVA_MAJOR_VERSION}"u"${JAVA_UPDATE_VERSION}"-linux-x64.tar.gz
ENV JAVA_OUTPUT_FILE="${JAVA_DISTRIBUTION}"-"${JAVA_MAJOR_VERSION}"u"${JAVA_UPDATE_VERSION}"-linux-x64.tar.gz
ENV PATH=$PATH:$JAVA_HOME/bin

RUN # Install tooling
    apk add --update \
      ca-certificates \
      wget curl && \
    # Install latest glibc
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-${GLIBC_VERSION}.apk && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-bin-${GLIBC_VERSION}.apk && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    apk --allow-untrusted add /tmp/glibc-i18n-${GLIBC_VERSION}.apk && \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    # Install oracle java
    curl --silent --location --retry 3 --cacert /etc/ssl/certs/ca-cert-GeoTrust_Global_CA.pem \
    	--header "Cookie: oraclelicense=accept-securebackup-cookie;" \
    	${JAVA_DOWNLOAD_URL} \
    	-o /tmp/${JAVA_OUTPUT_FILE} && \
    mkdir -p /opt/java && \
    tar -xzf /tmp/${JAVA_OUTPUT_FILE} -C /opt/java/ && \
    if  [ "${JAVA_DISTRIBUTION}" = "server-jre" ]; \
      then mv /opt/java/jdk${JAVA_VERSION} ${JAVA_HOME} ; \
    fi && \
    ln -s ${JAVA_HOME}/bin/java /usr/bin/java && \
    # Remove obsolete packages
    apk del \
      ca-certificates \
      wget \ 
      curl && \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*
