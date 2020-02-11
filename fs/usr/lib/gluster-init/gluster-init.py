import os
import sys
import time
import socket
from gluster_cli import GlusterCli
from configuration import Configuration

text_file = open("/tmp/test.txt", "w")
text_file.write("Some text")
text_file.close()

# If node is not master, it should not execute any configuration commands
if(not "MASTER" in os.environ or os.getenv("MASTER") == ""):
  print("Node is not a master, exitting the configurer...")
  sys.exit(0)

print("Waiting for Gluster to get ready...")
GlusterCli.wait_until_ready(30)

while True:
  # Load configuration via py_yaml
  config = Configuration.load()

  # TODO: Validate the configuration, if validation does not pass, skip this run and goto sleep

  working_nodes = []

  # Add nodes to the gluster
  # for node in config['nodes']:
  #   if(GlusterCli.peer_probe(node)):
  #     print("Adding node " + node + " successful (or was already a part of the gluster)")
  #     working_nodes.append(node)
  #   else:
  #     print("Adding node has failed, will retry in the next tick")
  #GlusterCli.pool_status()

  print("Total nodes: ", str(len(config['nodes'])))
  print("Working nodes: ", str(len(working_nodes)))

  if(len(working_nodes) == len(config['nodes'])):
    print("All nodes up and working :)")

  #for volume in config['volumes']:
    # Check if exists
    # If not, check if all nodes required for the volumes are in the cluster
    # If they are, try to create the volume



  time.sleep(10) # Depends if all ok or not


# if "SWARM_SERVICE_NAME" in os.environ:
#   print("Running in swarm mode...")
#   # Running in Swarm mode
#   service_instances = Dns.lookup_service_instances(str(os.getenv("SWARM_SERVICE_NAME")))

#   for instance in service_instances:
#     print(instance)
#     #GlusterCli.peer_probe(instance, 60)

#   GlusterCli.pool_status()
# else:
#   print("Variable SWARM_SERVICE_NAME was not set. Skipping the automatic cluster set up")



# #   if(os.environ['ALLOWED_CLIENTS'] != "")
# #     print("Using ALLOWED_CLIENTS env. variable for auth.allow")
# #     GlusterCli.set_auth(os.environ['ALLOWED_CLIENTS'])
# #   else
# #     print("ALLOWED_CLIENTS not set, setting auth.allow to gluster nodes only")
# #     GlusterCli.set_auth(",".join(service_instances))


# # else:
# #   if(os.environ['ALLOWED_CLIENTS'] != "")
# #     print("Using ALLOWED_CLIENTS env. variable for auth.allow")
# #     GlusterCli.set_auth(os.environ['ALLOWED_CLIENTS'])
# #   else
# #     print("ALLOWED_CLIENTS not set, setting auth.allow to allow any client (*)")
# #     GlusterCli.set_auth("*")



# # Post start set up
# # =====================================
# #   If SWARM_SERVICE_NAME is not empty:
# #       - resolve the other nodes by *.tasks dns lookup and do gluster peer probe
# #       - set allowed clients according to ENV (if empty => tasks, use hostnames, not IPs)
# #   Else
# #       - set allowed clients according to ENV (if empty => *)
# #   End if
# #
# #   Create volumes per definitions (if they don't already exist)
# #      Volumes definition -> yaml config (docker config shared accross the cluster mounted at /config/volumes.yml)