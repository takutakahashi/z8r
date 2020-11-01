from kubernetes import client, config


class Replication():
    MASTER = "zfs.repl.takutakahashi.dev/master"
    REPLICA = "zfs.repl.takutakahashi.dev/replica"

    def __init__(self, use_service_account=True):
        if use_service_account:
            config.load_incluster_config()
        else:
            config.load_kube_config()
        self.v1 = client.CoreV1Api()
        print("kubernetes client is ready.")

    def get_labels(self):
        return {i.metadata.name: i.metadata.annotations
                for i in self.v1.list_node().items}

    def make_repl_dataset(self):
        nodes = self.get_labels()

        def filter_label(labels, label_type):
            li = [v.split(",") for k, v in labels.items() if label_type in k]
            return [] if len(li) == 0 else li.pop()
        nodes = {node: {
                      "master": filter_label(labels, self.MASTER),
                      "replica": filter_label(labels, self.REPLICA),
                  } for node, labels in nodes.items()}
        replsets = {}
        for node, d in nodes.items():
            for master_pool in d["master"]:
                replsets[master_pool] = {"master": node}
        for node, d in nodes.items():
            for replica_pool in d["replica"]:
                if not replsets.get(replica_pool):
                    continue
                replsets[replica_pool]["replica"] = node
        return replsets
