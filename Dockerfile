FROM spark:python3

USER root

RUN apt update
RUN apt-get update
RUN apt install sudo -y
RUN apt install vim -y
RUN apt install -y openssh-server
RUN mkdir -p /run/sshd
RUN apt install wireguard -y
RUN apt-get install -y iproute2
RUN apt-get install -y iputils-ping
RUN apt-get install jq -y
# RUN wg genkey | sudo tee /etc/wireguard/private.key
# RUN chmod go= /etc/wireguard/private.key
# RUN cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
RUN echo "root:l" | chpasswd
RUN echo "spark:l" | chpasswd
RUN usermod -aG sudo spark
RUN mkdir /home/spark
RUN chown -R spark:spark /home/spark
RUN echo "PATH=\"/opt/spark/bin:${PATH}\"" > /home/spark/.bashrc

COPY write_conf.sh /usr/local/bin/write_sparkk_conf.sh
RUN chmod +x /usr/local/bin/write_sparkk_conf.sh

# Download dependencies for spark
wget -P /opt/spark/jars https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar
wget -P /opt/spark/jars https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.608/aws-java-sdk-bundle-1.12.608.

ENTRYPOINT ["/usr/local/bin/write_sparkk_conf.sh"]

CMD ["bash"]
