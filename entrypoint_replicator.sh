#!/bin/bash

ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
mv /root/.ssh/id_rsa.pub /var/www/html/
nginx
sleep 40
kubectl get pod -o wide -n zrepl |grep node-daemon|awk '{print $6," ",$7}' >> /etc/hosts
test "$DEBUG" = "true" && (echo "debug mode"; sleep infinity) || python3 /exec_replication.py
