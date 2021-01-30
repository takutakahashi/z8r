#!/bin/bash -x

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
DSTIP=`cat /etc/hosts |grep $DSTHOST |awk '{print $1}'`
src_last_snapshot=`ssh $SRCHOST zfs list -t snapshot $SRCPOOL |grep -v NAME |awk '{print $1}' |sort |tail -1`
dst_last_snapshot=`ssh $DSTHOST zfs list -t snapshot $DSTPOOL |grep -v NAME |awk '{print $1}' |sort |tail -1`
src_first_snapshot=`ssh $SRCHOST zfs list -t snapshot $SRCPOOL |grep -v NAME |awk '{print $1}' |sort |head -1`
dst_first_snapshot=`ssh $DSTHOST zfs list -t snapshot $DSTPOOL |grep -v NAME |awk '{print $1}' |sort |head -1`
if [[ "$dst_last_snapshot" = "$src_last_snapshot" ]]; then
    exit 0
fi
if [[ "$dst_first_snapshot" = "" ]]; then
    PORT=`comm -23 <(seq 49152 65535 | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf | head -n 1`
    ssh $DSTHOST "nc -l -p $PORT -w 120 | zfs recv $DSTPOOL -F" &
    ssh $SRCHOST "zfs send $src_first_snapshot | nc $DSTIP $PORT"
    ssh $DSTHOST "ps aux |grep nc |grep $PORT |awk '{print \$2}' |xargs -I{} kill -9 {}"
elif [[ `echo $dst_first_snapshot |awk -F'@' '{print $2}'` -lt `echo $src_first_snapshot |awk -F'@' '{print $2}'` ]]; then
    ssh $DSTHOST zfs destroy $dst_first_snapshot
fi
PORT=`comm -23 <(seq 49152 65535 | sort) <(ss -Htan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf | head -n 1`
ssh $DSTHOST "nc -l -p $PORT -w 120 | zfs recv $DSTPOOL -F" &
ssh $SRCHOST "zfs send -I $src_first_snapshot $src_last_snapshot | nc $DSTIP $PORT"
ssh $DSTHOST "ps aux |grep nc |grep $PORT |awk '{print \$2}' |xargs -I{} kill -9 {}"
