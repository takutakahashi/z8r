from lib.k8s import Replication
import subprocess
import time
import os

repl = Replication()
node_name = os.environ.get("NODE_NAME")
if node_name is None:
    print("NODE_NAME is not defined")
    exit(1)
while True:
    for pool, replset in filter(
            lambda k: k[1]["master"] == node_name,
            repl.make_repl_dataset().items()):
        cmd = ["/snapshot.sh", pool]
        print("{} snapshot started".format(pool))
        proc = subprocess.run(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
        if proc.returncode != 0:
            print("{} snapshot failed : {}".format(
                pool, proc.stderr.decode("utf-8")))
        else:
            print("{} snapshot succeeded".format(pool))
    time.sleep(6 * 60 * 60)
