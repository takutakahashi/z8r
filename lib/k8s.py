from kubernetes import client, config
import yaml

class Replication():
    MASTER = "zfs.repl.takutakahashi.dev/master"
    REPLICA = "zfs.repl.takutakahashi.dev/replica"

    def __init__(self, use_service_account=True):
        if use_service_account:
            config.load_incluster_config()
        else:
            config.load_kube_config()
        self.v1 = client.CoreV1Api()

    def get_labels(self):
        return {i.metadata.name: i.metadata.annotations
                for i in self.v1.list_node().items}

    # repl dataset: 
    # [{"master": "host1:tank/data", "replica": "host2:tank/data"}]
    def make_repl_dataset(self):
        config = []
        with open('/etc/z8r/config.yaml') as file:
            config = yaml.safe_load(file)
        return config