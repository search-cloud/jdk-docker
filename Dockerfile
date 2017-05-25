# Alpine-Linux with a glibc-2.25 and Oracle Java 8
FROM alpine:3.5

MAINTAINER Asion <luxuexian99@gmial.com>

# Java Version and other ENV time zone
ENV JAVA_VERSION_MAJOR=8 \
    JAVA_VERSION_MINOR=131 \
    JAVA_VERSION_BUILD=11 \
    JAVA_PACKAGE=jdk \
    JAVA_JCE=unlimited \
    JAVA_HOME=/usr/share/java/jdk \
    PATH=${PATH}:/usr/share/java/jdk/bin \
    GLIBC_VERSION=2.25-r0 \
    LANG=C.UTF-8 \
    TZ=Asia/Shanghai

# all in one step
# 1) install glibc
# 2) install jdk
# 3) instsll jce
# 4) clean package
RUN set -ex && \
    apk upgrade --update && \
    apk add --update libstdc++ curl ca-certificates bash tzdata && \
    ls /usr/share/zoneinfo && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && date && \

    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \

    curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/java.tar.gz \
      http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/d54c1d3a095b4ff2b6607d096fa80163/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
    mkdir /usr/share/java && \
    gunzip /tmp/java.tar.gz && \
    tar -C /usr/share/java -xf /tmp/java.tar && \
    ln -s /usr/share/java/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /usr/share/java/jdk && \

    if [ "${JAVA_JCE}" == "unlimited" ]; then echo "Installing Unlimited JCE policy" >&2 && \
      curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/jce_policy-${JAVA_VERSION_MAJOR}.zip \
            http://download.oracle.com/otn-pub/java/jce/${JAVA_VERSION_MAJOR}/jce_policy-${JAVA_VERSION_MAJOR}.zip && \
      cd /tmp && unzip /tmp/jce_policy-${JAVA_VERSION_MAJOR}.zip && cp -v /tmp/UnlimitedJCEPolicyJDK8/*.jar /usr/share/java/jdk/jre/lib/security; \
    fi && \
    sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=10/ $JAVA_HOME/jre/lib/security/java.security && \

    apk del glibc-i18n curl ca-certificates tzdata && \
    rm -rf /usr/share/java/jdk/*src.zip \
           /usr/share/java/jdk/lib/missioncontrol \
           /usr/share/java/jdk/lib/visualvm \
           /usr/share/java/jdk/lib/*javafx* \
           /usr/share/java/jdk/jre/plugin \
           /usr/share/java/jdk/jre/bin/javaws \
           /usr/share/java/jdk/jre/bin/jjs \
           /usr/share/java/jdk/jre/bin/orbd \
           /usr/share/java/jdk/jre/bin/pack200 \
           /usr/share/java/jdk/jre/bin/policytool \
           /usr/share/java/jdk/jre/bin/rmid \
           /usr/share/java/jdk/jre/bin/rmiregistry \
           /usr/share/java/jdk/jre/bin/servertool \
           /usr/share/java/jdk/jre/bin/tnameserv \
           /usr/share/java/jdk/jre/bin/unpack200 \
           /usr/share/java/jdk/jre/lib/javaws.jar \
           /usr/share/java/jdk/jre/lib/deploy* \
           /usr/share/java/jdk/jre/lib/desktop \
           /usr/share/java/jdk/jre/lib/*javafx* \
           /usr/share/java/jdk/jre/lib/*jfx* \
           /usr/share/java/jdk/jre/lib/amd64/libdecora_sse.so \
           /usr/share/java/jdk/jre/lib/amd64/libprism_*.so \
           /usr/share/java/jdk/jre/lib/amd64/libfxplugins.so \
           /usr/share/java/jdk/jre/lib/amd64/libglass.so \
           /usr/share/java/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /usr/share/java/jdk/jre/lib/amd64/libjavafx*.so \
           /usr/share/java/jdk/jre/lib/amd64/libjfx*.so \
           /usr/share/java/jdk/jre/lib/ext/jfxrt.jar \
           /usr/share/java/jdk/jre/lib/ext/nashorn.jar \
           /usr/share/java/jdk/jre/lib/oblique-fonts \
           /usr/share/java/jdk/jre/lib/plugin.jar \
           /tmp/* /var/cache/apk/* && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# EOF