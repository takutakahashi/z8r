from lib.k8s import Replication
import subprocess
import time

repl = Replication()
print(repl.make_repl_dataset())
for pool, replset in repl.make_repl_dataset().items():
    cmd = ["/replication.sh", pool, replset["master"], replset["replica"]]
    print("{} sync started: {} to {}".format(
        pool, replset["master"], replset["replica"]))
    proc = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    if proc.returncode != 0:
        print("{} sync failed : {}".format(
            pool, proc.stderr.decode("utf-8")))
    else:
        print("{} sync succeeded".format(pool))