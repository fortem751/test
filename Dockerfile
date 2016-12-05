\FROM registry.access.redhat.com/rhel7:latest
#FROM openshift/base-centos7

MAINTAINER DevOps Team <devops@openlaws.com>

ENV BUILDER_VERSION 0.1.17
ENV NEO4J_SHA256 f58450760a92b0913c5418e26278a6a65bf6c5ba01f9b12a033f56e80f0c3d23
ENV NEO4J_TARBALL neo4j-enterprise-3.0.6-unix.tar.gz
ENV DATA_DIR /data

ARG NEO4J_URI=http://dist.neo4j.org/neo4j-enterprise-3.0.6-unix.tar.gz

LABEL io.k8s.description="Platform for running neo4j 3.0.6 enterprice" \
      io.k8s.display-name="Neo4j 3.0.6 enterprice" \
      io.openshift.expose-services="7474:http,7473:https,7687:tcp" \
      io.openshift.tags="Neo4j, Neo4j3.0.6, Neo4j-enterprice, Neo4j3.0.6-enterprice"

# Install required packages:
RUN yum clean all \
    && yum update -y \
    && yum-config-manager --enable rhel-7-server-ose-3.2-rpms \
    && yum-config-manager --enable rhel-7-server-rpms \
    && yum repolist \
    && INSTALL_PKGS="gettext tar java-1.8.0-openjdk-headless which rsync net-tools ruby iproute" \
    && yum install -y $INSTALL_PKGS \
    && rpm -V $INSTALL_PKGS \
    && yum clean all \
    && localedef -f UTF-8 -i en_US en_US.UTF-8 \
    && rm /etc/localtime \
    && ln -s /usr/share/zoneinfo/GMT /etc/localtime

 VOLUME /data

# Install neo4j :
RUN set -x \
    && curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256} ${NEO4J_TARBALL}" | sha256sum --check --quiet - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL}

COPY container-files/ /

RUN set -x \
    && chmod 755 /docker-entrypoint.sh \
    && chmod 755 /healthcheck.sh 
#    && chmod 755 /pod_endpoints.rb

WORKDIR /var/lib/neo4j

# Drop the root user and make the content of /var/lib/neo4j owned by user 1001
RUN chgrp -R 0 /var/lib/neo4j \
    && chmod -R g+rw /var/lib/neo4j \
    && chmod -R g+rw /data 

# This default user is created in the openshift/rhel7 image
# USER 1001

# Set the default port for applications built using this image
EXPOSE 7474 7473 7687 5001 6001

ENTRYPOINT ["/docker-entrypoint.sh"]
