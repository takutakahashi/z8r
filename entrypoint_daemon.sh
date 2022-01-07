#!/bin/bash
kubectl get pod -o wide -n z8r |grep node-daemon|awk '{print $6," ",$7}' >> /etc/hosts
/usr/sbin/sshd
if [[ -e "/root/.ssh/authorized_keys" ]]; then
  sleep infinity
else
  while true; do
    curl replicator/id_rsa.pub 1>/root/.ssh/authorized_keys 2>/dev/null
    curl snapshot/id_rsa.pub 1>>/root/.ssh/authorized_keys 2>/dev/null
    sleep 5
  done
fi
