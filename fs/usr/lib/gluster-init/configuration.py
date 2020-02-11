import os
import subprocess
import yaml

class Configuration:
  def load():
    if("CONFIG_FILE_PATH" in os.environ and os.getenv("CONFIG_FILE_PATH") != ""):
      return Configuration.load_from_file(os.getenv("CONFIG_FILE_PATH"))

    return Configuration.load_from_rancher()

  def load_from_rancher():
    print("Loading configuration from RancherOS config")
    result = subprocess.run(["ros", "config", "get", "gluster"], stdout=subprocess.PIPE)

    return yaml.load(result.stdout, Loader=yaml.SafeLoader)

  def load_from_file(file_name: str):
    print("Loading configuration from file ", file_name)
    result = subprocess.run(["cat", file_name], stdout=subprocess.PIPE)

    print("File content: " + str(result.stdout))

    return yaml.load(result.stdout, Loader=yaml.SafeLoader)

