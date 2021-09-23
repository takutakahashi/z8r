#!/bin/bash

kubectl get pod -o wide -n z8r |grep node-daemon|awk '{print $6," ",$7}' >> /etc/hosts
test "$DEBUG" = "true" && (echo "debug mode"; sleep infinity) || python3 -u /exec_replication.py
