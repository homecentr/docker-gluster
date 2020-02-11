# HomeCentr - gluster
Template repository for Docker container repositories

## Project status

## Usage (Docker compose)

### Env. variables
### Exposed ports

## Security

### Vulnerabilities

## Configuring cluster from Rancher console
Because the console in RancherOS runs in a Docker container and the gluster runs in a different container, you can't execute gluster commands from the console. Gluster CLI unfortunately does not support managing a remote cluster (or at least I have not found a way how to do it) and communicates with local glusterd. To make this a bit easier, I have created a bash script which will execute the gluster commands inside of the glusterfs container. You can download the script using the command below.

```bash
curl https://raw.githubusercontent.com/homecentr/docker-rancher-gluster/master/gluster.sh --output /usr/sbin/gluster
```