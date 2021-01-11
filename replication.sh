#!/bin/bash -e

SRCHOST=$1
SRCPOOL=$2
DSTHOST=$3
DSTPOOL=$4

if [[ "$SRCPOOL" = "" ]]; then
  echo "no pool"
  exit 1
fi
if [[ "$DSTPOOL" = "" ]]; then
  echo "no pool"
  exit 1
fi
if [[ "$SRCHOST" = "" ]]; then
  echo "no src"
  exit 1
fi
if [[ "$DSTHOST" = "" ]]; then
  echo "no dst"
  exit 1
fi

src_last_snapshot=`ssh $SRCHOST zfs list -t snapshot $SRCPOOL |grep -v NAME |awk '{print $1}' |sort |tail -1`
dst_last_snapshot=`ssh $DSTHOST zfs list -t snapshot $DSTPOOL |grep -v NAME |awk '{print $1}' |sort |tail -1`
src_first_snapshot=`ssh $SRCHOST zfs list -t snapshot $SRCPOOL |grep -v NAME |awk '{print $1}' |sort |head -1`
dst_first_snapshot=`ssh $DSTHOST zfs list -t snapshot $DSTPOOL |grep -v NAME |awk '{print $1}' |sort |head -1`
if [[ "$dst_last_snapshot" = "$src_last_snapshot" ]]; then
    exit 0
fi
if [[ "$dst_first_snapshot" = "" ]]; then
    ssh $SRCHOST zfs send $src_first_snapshot | curl -T - pipe/$DSTPOOL/$src_first_snapshot &
    ssh $DSTHOST "curl pipe/$DSTPOOL/$src_first_snapshot | zfs recv $DSTPOOL -F"
elif [[ `echo $dst_first_snapshot |awk -F'@' '{print $2}'` -lt `echo $src_first_snapshot |awk -F'@' '{print $2}'` ]]; then
    ssh $DSTHOST zfs destroy $dst_first_snapshot
fi
ssh $SRCHOST zfs send -I $src_first_snapshot $src_last_snapshot | curl -T - pipe/$DSTPOOL/$src_first_snapshot/$src_last_snapshot &
ssh $DSTHOST "curl pipe/$DSTPOOL/$src_first_snapshot/$src_last_snapshot | zfs recv $DSTPOOL -F"
