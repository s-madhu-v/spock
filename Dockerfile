FROM spark:python3

USER root

RUN apt update
RUN apt-get update
RUN apt install sudo -y
RUN apt install vim -y
RUN apt install wireguard -y
RUN apt-get install -y iproute2
RUN apt-get install -y iputils-ping
RUN apt-get install jq -y
RUN wg genkey | sudo tee /etc/wireguard/private.key
RUN chmod go= /etc/wireguard/private.key
RUN cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
RUN echo "root:l" | chpasswd
RUN echo "spark:l" | chpasswd
RUN usermod -aG sudo spark
RUN mkdir /home/spark
RUN chown -R spark:spark /home/spark
RUN echo "PATH=\"/opt/spark/bin:${PATH}\"" > /home/spark/.bashrc

ENTRYPOINT ["write_conf.sh"]

CMD ["bash"]