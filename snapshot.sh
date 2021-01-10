#!/bin/bash
HOST=$1
POOL=$2
if [[ "$HOST" = "" ]]; then
  echo "no host"
  exit 1
fi
if [[ "$POOL" = "" ]]; then
  echo "no pool"
  exit 1
fi
last_snapshot=`ssh $HOST zfs list -t snapshot $POOL |grep -v NAME |awk '{print $1}' |sort |tail -1 |awk -F'@' '{print $2}'`
next_snapshot=`date "+%Y%m%d%H"`
diff=`expr $next_snapshot - $last_snapshot`
if [[ $diff -gt 6 ]]; then
  ssh $HOST zfs snapshot ${POOL}@${next_snapshot}
  echo "snapshot succeded ${HOST}:${POOL}@${next_snapshot}"
fi
# delete snapshot
CNT=`ssh $HOST zfs list -t snapshot $POOL |grep -v NAME |wc -l`
if [[ $CNT -gt 21 ]]; then
  DEL=`ssh $HOST zfs list -t snapshot $POOL |grep -v NAME | head -1 |awk '{print $1}'`
  ssh $HOST zfs destroy $DEL
  echo "deleted snapshot $DEL"
fi
