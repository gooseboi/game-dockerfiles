FROM alpine:20231219

# https://github.com/adoptium/containers/issues/319#issuecomment-1334960460
RUN apk add --update wget ca-certificates openssl libgcc rsync && \
    rm -f ~/.wget-hsts && \
    rm -rf /var/cache/apk/*

ARG java_jdk_url="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jre_x64_alpine-linux_hotspot_8u392b08.tar.gz"
WORKDIR /java
RUN wget -O java.tar.gz -L $java_jdk_url && \
    rm -f ~/.wget-hsts && \
    tar xzvf java.tar.gz && \
    rm java.tar.gz && \
    mv /java/jdk*/* /java && \
    rm -rf /java/jdk*
ENV PATH=/java/bin:${PATH}

ARG packwiz_installer_bootstrap_url="https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar"
WORKDIR /data
COPY pack pack
RUN wget -O packwiz-installer-bootstrap.jar $packwiz_installer_bootstrap_url && \
    rm -rf ~/.wget-hsts /tmp/hsperfdata_root && \
    rm -rf /tmp/hsperfdata_root && \
    java -jar packwiz-installer-bootstrap.jar -g -s server ./pack/pack.toml && \
    rm -rf pack packwiz.json packwiz-installer.jar packwiz-installer-bootstrap.jar

RUN wget -O forge-installer.jar 'https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2859/forge-1.12.2-14.23.5.2859-installer.jar' && \
    java -jar forge-installer.jar -installServer && \
    rm -rf forge-installer.jar forge-installer.jar.log && \
    echo "eula=true" > eula.txt

COPY user_jvm_args.txt user_jvm_args.txt

EXPOSE 25565
VOLUME /server

COPY --chmod=755 start.sh /start.sh

ENTRYPOINT ["/start.sh"]
