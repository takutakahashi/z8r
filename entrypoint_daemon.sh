#!/bin/bash

/usr/sbin/sshd
python3 /exec_snapshot.py &
while true; do
  curl replicator/id_rsa.pub 1>/root/.ssh/authorized_keys 2>/dev/null
  sleep 10
done
