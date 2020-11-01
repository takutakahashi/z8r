#!/bin/bash
POOL=$1
zfs list -t snapshot $POOL
if [[ "$POOL" = "" ]]; then
  echo "no pool"
  exit 1
fi
last_snapshot=`zfs list -t snapshot $POOL |grep -v NAME |awk '{print $1}' |sort |tail -1 |awk -F'@' '{print $2}'`
next_snapshot=`date "+%Y%m%d%H"`
diff=`expr $next_snapshot - $last_snapshot`
if [[ $diff -gt 6 ]]; then
  zfs snapshot ${POOL}@${next_snapshot}
  echo "snapshot succeded ${POOL}@${next_snapshot}"
fi
