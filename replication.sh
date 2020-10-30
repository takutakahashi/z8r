#!/bin/bash -e

POOL=$1
SRC=$2
DST=$3

if [[ "$POOL" = "" ]]; then
  echo "no pool"
  exit 1
fi
if [[ "$SRC" = "" ]]; then
  echo "no src"
  exit 1
fi
if [[ "$DST" = "" ]]; then
  echo "no dst"
  exit 1
fi

src_last_snapshot=`ssh $SRC zfs list -t snapshot $POOL |grep -v NAME |awk '{print $1}' |sort |tail -1`
src_first_snapshot=`ssh $SRC zfs list -t snapshot $POOL |grep -v NAME |awk '{print $1}' |sort |head -1`
dst_first_snapshot=`ssh $DST zfs list -t snapshot $POOL |grep -v NAME |awk '{print $1}' |sort |head -1`
if [[ "$dst_first_snapshot" = "" ]]; then
    ssh $SRC zfs send $src_first_snapshot |ssh $DST zfs recv $POOL -F
elif [[ `echo $dst_first_snapshot |awk -F'@' '{print $2}'` -lt `echo $src_first_snapshot |awk -F'@' '{print $2}'` ]]; then
    ssh $DST zfs destroy $dst_first_snapshot
fi
ssh $SRC zfs send -I $src_first_snapshot $src_last_snapshot |ssh $DST zfs recv $POOL
