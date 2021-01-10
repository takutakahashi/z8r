from lib.k8s import Replication
import subprocess
import os

repl = Replication()

for replset in repl.make_snapshot_dataset()["targets"]:
    host, pool = replset.split(":")
    cmd = ["/snapshot.sh", host, pool]
    if os.environ.get("DEBUG") == "true":
        cmd = ["echo", "/snapshot.sh", host, pool]
        print(cmd)
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
