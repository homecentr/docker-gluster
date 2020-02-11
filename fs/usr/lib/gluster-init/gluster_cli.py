import os
import time

class GlusterCli:
  def wait_until_ready(timeoutSeconds: int) -> bool:
    print("Waiting for local gluster to start...")
    wait_threshold = time.time() + timeoutSeconds

    while 0 != os.system("gluster pool list > /dev/null") and wait_threshold < time.time():
      print("Waiting for local gluster to start...")
      time.sleep(10)

    if 0 != os.system("gluster pool list > /dev/null"):
      raise ProcessLookupError("gluster did not start in time")

    print("Local gluster is running")

  def peer_probe(hostname: str) -> bool:
    exit_code = os.system("gluster peer probe \"" + hostname + "\"")

    return exit_code == 0

  def pool_status():
    print("Listing pool status...")
    os.system("gluster pool list")