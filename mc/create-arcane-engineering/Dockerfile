FROM debian:bookworm-20231218-slim

ARG java_jdk_url="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jdk_x64_linux_hotspot_17.0.9_9.tar.gz"
ARG modpack_server_url="https://mediafilez.forgecdn.net/files/4852/56/CAEServer1.9.zip"

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip ca-certificates rsync && \
    rm -f ~/.wget-hsts && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log /var/cache/debconf

WORKDIR /java
RUN wget -O java.tar.gz -L $java_jdk_url && \
	tar xzvf java.tar.gz && \
	rm java.tar.gz && \
	mv /java/jdk*/* /java && \
	rm -rf /java/jdk* /root/.wget-hsts

ENV PATH=/java/bin:${PATH}

WORKDIR /data
RUN wget -O sv.zip $modpack_server_url && \
	unzip sv.zip && \
	rm sv.zip && \
	wget -O "forge-installer.jar" "http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-40.2.9/forge-1.18.2-40.2.9-installer.jar" && \
	java -jar forge-installer.jar -installServer && \
	rm -f forge-installer.jar forge-installer.jar.log \
	run.sh run.bat startserver.bat startserver.sh VeryMakeShiftHowTo.txt && \
	echo "eula=true" > eula.txt

COPY --chmod=755 start.sh /start.sh

VOLUME /server
EXPOSE 25565

CMD ["/start.sh"]
