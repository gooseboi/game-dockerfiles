FROM alpine:20231219

# GCC for tls (I don't want to check what dep of it gives tls)
RUN apk add --update wget unzip rsync gcc && \
    rm -f ~/.wget-hsts && \
    rm -rf /var/cache/apk/*

ARG java_jdk_url="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u402-b06/OpenJDK8U-jre_x64_alpine-linux_hotspot_8u402b06.tar.gz"
WORKDIR /java
RUN wget -O java.tar.gz -L $java_jdk_url && \
    tar xzvf java.tar.gz && \
    rm java.tar.gz && \
    mv /java/jdk*/* /java && \
    rm -rf /java/jdk* /root/.wget-hsts

ENV PATH=/java/bin:${PATH}

ARG modpack_server_url="https://mediafilez.forgecdn.net/files/3570/46/SevTech_Ages_Server_3.2.3.zip"
WORKDIR /data
RUN wget -O sv.zip $modpack_server_url && \
    unzip sv.zip && \
    rm sv.zip *.bat && \
    java -jar "forge-1.12.2-14.23.5.2860-installer.jar" -installServer && \
    rm -f "forge-1.12.2-14.23.5.2860-installer.jar" forge-installer.jar.log \
	Install.sh ServerStart.sh settings.sh && \
    echo "eula=true" > eula.txt

COPY user_jvm_args.txt user_jvm_args.txt

VOLUME /server
EXPOSE 25565

COPY --chmod=755 start.sh /start.sh

CMD ["/start.sh"]
