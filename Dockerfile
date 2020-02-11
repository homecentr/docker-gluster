ARG GLUSTERFS_VERSION="6.7-1.el8"

###
### Download GlusterFS repo definition file
###
FROM alpine:3.11.3 as repo-tmp

RUN date && apk add --no-cache wget=1.20.3-r0 && \
    wget https://download.gluster.org/pub/gluster/glusterfs/6/LATEST/CentOS/glusterfs-rhel8.repo -P /tmp/

###
### Download S6 Overlay
###
FROM alpine:3.11.3 as s6-tmp

ENV S6_VERSION="v1.22.1.0"
ENV CPU_ARCH="amd64"

ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${CPU_ARCH}.tar.gz /tmp/

    # Create a directory where to extract S6
RUN mkdir /s6 && \
    # Extract the S6 tarball
    tar xzf /tmp/s6-overlay-${CPU_ARCH}.tar.gz -C /s6 && \
    # Move the binary to a separate folder to avoid the issue with overriding symlinks
    cp -r /s6/bin/. /s6/usr/bin/ && \
    rm -rf /s6/bin

###
### Final image
###
FROM centos:8

ARG GLUSTERFS_VERSION

ENV SWARM_SERVICE_NAME=""

LABEL maintainer="Lukas Holota <me@lholota.com>"
LABEL org.homecentr.dependency-version=$GLUSTERFS_VERSION

COPY --from=repo-tmp /tmp/glusterfs-rhel8.repo /etc/yum.repos.d/glusterfs-rhel8.repo
COPY --from=s6-tmp /s6 /

    # Install GlusterFS
RUN dnf --enablerepo=PowerTools -y install glusterfs-server-$GLUSTERFS_VERSION && \
    # Move the configuration to a different folder so the actual one can become a volume
    mv /etc/glusterfs /etc/glusterfs-default && \
    # Install configurer dependencies
    pip3 install pyyaml==5.3

# Copy S6 configuration
COPY ./fs/ /

# Remove Pythom tmp files
RUN rm -rf /usr/lib/gluster-init/__pycache__

VOLUME /var/log/glusterfs
VOLUME /etc/glusterfs
VOLUME /var/lib/glusterd

# List of ports is based on the official Docker image
EXPOSE 2222 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162

ENTRYPOINT [ "/init" ]

# Post start set up
# =====================================
# Wait for local gluster process to start and get ready (via gluster pool list or other command)
#   If SWARM_SERVICE_NAME is not empty:
#       - resolve the other nodes by *.tasks dns lookup and do gluster peer probe
#       - set allowed clients according to ENV (if empty => tasks, use hostnames, not IPs)
#   Else
#       - set allowed clients according to ENV (if empty => *)
#   End if
#
#   Create volumes per definitions (if they don't already exist)
#      Volumes definition -> yaml config (docker config shared accross the cluster mounted at /config/volumes.yml)