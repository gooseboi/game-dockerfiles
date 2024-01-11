FROM debian:bookworm-20231218-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip ca-certificates rsync && \
    rm -f ~/.wget-hsts && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log /var/cache/debconf

ARG java_jdk_url="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u392-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u392b08.tar.gz"
WORKDIR /java
RUN wget -O java.tar.gz -L $java_jdk_url && \
    tar xzvf java.tar.gz && \
    rm java.tar.gz && \
    mv /java/jdk*/* /java && \
    rm -rf /java/jdk* /root/.wget-hsts

ENV PATH=/java/bin:${PATH}

ARG modpack_server_url="https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.5.1_Server_Java_8.zip"
WORKDIR /data
RUN wget -O sv.zip $modpack_server_url && \
    unzip sv.zip && \
    rm sv.zip && \
    rm startserver.sh startserver.bat changelog*

COPY user_jvm_args.txt user_jvm_args.txt
COPY start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /server
EXPOSE 25565

ENTRYPOINT ["/start.sh"]
