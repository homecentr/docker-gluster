ARG GLUSTERFS_REPO_MAJOR_VERSION="7"
ARG GLUSTERFS_REPO_MINOR_VERSION="7.4"
ARG GLUSTERFS_PACKAGE_VERSION="7.4-1.el8"

###
### Download GlusterFS repo definition file
###
FROM alpine:3.11.5 as repo-tmp

ARG GLUSTERFS_REPO_MAJOR_VERSION
ARG GLUSTERFS_REPO_MINOR_VERSION

RUN apk add --no-cache wget=1.20.3-r0 && \
    wget "https://download.gluster.org/pub/gluster/glusterfs/${GLUSTERFS_REPO_MAJOR_VERSION}/${GLUSTERFS_REPO_MINOR_VERSION}/CentOS/glusterfs-rhel8.repo" -P /tmp/

###
### Download S6 Overlay
###
FROM homecentr/base:centos-1.2.1 as base

###
### Final image
###
FROM centos:8

ARG GLUSTERFS_PACKAGE_VERSION

LABEL maintainer="Lukas Holota <me@lholota.com>"
LABEL org.homecentr.dependency-version=$GLUSTERFS_PACKAGE_VERSION

COPY --from=repo-tmp /tmp/glusterfs-rhel8.repo /etc/yum.repos.d/glusterfs-rhel8.repo
COPY --from=base / /

    # Install GlusterFS
RUN dnf --enablerepo=PowerTools -y install glusterfs-server-$GLUSTERFS_PACKAGE_VERSION && \
    # Move the configuration to a different folder so the actual one can become a volume
    mv /etc/glusterfs /etc/glusterfs-default

# Copy S6 configuration
COPY ./fs/ /

VOLUME /var/log/glusterfs
VOLUME /etc/glusterfs
VOLUME /var/lib/glusterd

# List of ports is based on https://www.jamescoyle.net/how-to/457-glusterfs-firewall-rules

# Port mapper
EXPOSE 111/tcp 111/udp

# Gluster daemon
EXPOSE 24007/tcp

# Glusterd management
EXPOSE 24008/tcp

# Bricks ports (there may be more open ports higher than 49152 depending on the number of bricks)
# but Docker does not like a large number of explicitly exposed ports, hence just these are specified.
EXPOSE 49152-49155/tcp

# NFS service
EXPOSE 38465-38467/tcp

ENTRYPOINT [ "/init" ]