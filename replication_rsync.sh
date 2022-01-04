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
SRCMNT=`ssh $SRCHOST zfs list -o name,mountpoint |grep $SRCPOOL |awk '{print $1}'`
DSTMNT=`ssh $DSTHOST zfs list -o name,mountpoint |grep $DSTPOOL |awk '{print $1}'`
echo "check mountpoint"
test "$SRCMNT" = "-" && exit 1
test "$DSTMNT" = "-" && exit 1
echo "mount pool"
ssh $SRCHOST zfs mount $SRCPOOL
ssh $DSTHOST zfs mount $DSTPOOL
echo "start sync"
ssh $SRCHOST rsync -rvn --checksum /$SRCMNT/ $DSTHOST:$DSTMNT
