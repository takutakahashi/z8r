from lib.k8s import Replication
import subprocess
import time

repl = Replication()
print(repl.make_repl_dataset())
for replset in repl.make_repl_dataset():
    src_host, src_pool = replset["master"].split(":")
    dst_host, dst_pool = replset["replica"].split(":")
    cmd = ["/replication.sh", src_host, src_pool, dst_host, dst_pool]
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