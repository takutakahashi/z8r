FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y zfsutils wget curl openssh-server nginx python3.8 python3-pip \
 && wget https://github.com/zrepl/zrepl/releases/download/v0.3.0/zrepl-linux-amd64 -O /bin/zrepl \
 && chmod +x /bin/zrepl \
 && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && chmod +x kubectl \
 && mv kubectl /bin/

RUN pip3 install kubernetes

RUN mkdir /run/sshd
RUN mkdir /root/.ssh
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
COPY entrypoint_daemon.sh /
COPY entrypoint_replicator.sh /
COPY exec_replication.py /
COPY replication.sh /
COPY ssh_config /root/.ssh/config
