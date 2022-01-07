from lib.k8s import Replication
import subprocess
import os

repl = Replication()
print(repl.make_repl_dataset())
for replset in repl.make_repl_dataset():
    src_host, src_pool = replset["master"].split(":")
    dst_host, dst_pool = replset["replica"].split(":")
    repl_type = os.environ.get("REPLICATION_TYPE")
    if repl_type == "":
        repl_type = "zfs"
    shell = "/replication_{}.sh".format(repl_type)
    cmd = [shell, src_host, src_pool, dst_host, dst_pool]
    if os.environ.get("DEBUG") == "true":
        cmd = ["echo", shell, src_host, src_pool, dst_host, dst_pool]
    print("sync started: {} to {}".format(
        replset["master"], replset["replica"]))
    proc = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    if proc.returncode != 0:
        print("{} sync failed : {}".format(
            src_pool, proc.stderr.decode("utf-8")))
    else:
        print("{} to {} sync succeeded".format(src_pool, dst_pool))
