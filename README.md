# z8r

z8r is a kubernetes-native zfs replication system.  
The name "z8r" is an abbreviation for "zfs-on-kube replication"

## Overview

z8r can handle replication strategies by zfs datasets.

## How to use

### 1. Deploy it

You can deploy it by a following commands.

```
git clone https://github.com/takutakahashi/z8r
cd z8r/deploy
kubectl apply -f .
```

### 2. Annotate to nodes

You need to annotate to your nodes with following syntax.

Annotate node that have master dataset:

```
zfs.replication.takutakahashi.dev/master=tank/dataset1,tank/dataset2
```

You can set multiple datasets separated with comma.

Annotate to node that will be located replica:

```
zfs.replication.takutakahashi.dev/replica=tank/dataset1,tank/dataset2
```

Once you deployed and annotated to nodes, sync will be started.

## Featrues

### 1. Handling replication

You can handle replication strategies by zfs datasets, not pools.

For example, There are 2 nodes that have the same named pool: node1 and node2.

You can make replications with following annotations.

On node1:
```
zfs.replication.takutakahashi.dev/master=tank/dataset1
zfs.replication.takutakahashi.dev/replica=tank/dataset2
```

On node2:
```
zfs.replication.takutakahashi.dev/master=tank/dataset2
zfs.replication.takutakahashi.dev/replica=tank/dataset1
```

Then, tank/dataset1 will be replicated from node1 to node2
and tank/dataset2 will be replicated from node2 to node1.

## Future works

- [ ] Multiple replica
- [ ] Replication to another named datasets (ex: tank/data to tank2/data2)
- [ ] Parallel sync for pools that not share devices
- [ ] Use NetworkPolicy and non-encryption transfer
