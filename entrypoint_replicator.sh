#!/bin/bash

echo "preparing ssh public key"
ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
mv /root/.ssh/id_rsa.pub /var/www/html/
nginx
echo "waiting nodes are ready"
sleep 40
kubectl get pod -o wide -n z8r |grep node-daemon|awk '{print $6," ",$7}' >> /etc/hosts
echo "staring replicator"
test "$DEBUG" = "true" && (echo "debug mode"; sleep infinity) || exec python3 -u /exec_replication.py
