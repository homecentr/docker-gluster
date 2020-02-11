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

LABEL maintainer="Lukas Holota <me@lholota.com>"
LABEL org.homecentr.dependency-version=$GLUSTERFS_VERSION

COPY --from=repo-tmp /tmp/glusterfs-rhel8.repo /etc/yum.repos.d/glusterfs-rhel8.repo
COPY --from=s6-tmp /s6 /

    # Install GlusterFS
RUN dnf --enablerepo=PowerTools -y install glusterfs-server-$GLUSTERFS_VERSION && \
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