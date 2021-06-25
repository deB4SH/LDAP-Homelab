FROM lab.0x09.de:61000/homelab/base:latest
MAINTAINER deB4SH <hello@b4sh.de>
#=========================
# This container provides a basic debian installation plus a ldap service.
# It auto exposes the ldap and ldaps ports.
# For using ldaps you need to extend this image and follow the guide under following url.
# +
# If you want to store the data that get stored inside that ldap container please mount /var/lib/ldap as data volume from outside.
# +
# Your could replace the FROM with your own debian base image
#=========================
ENV DEBUG_LEVEL=256
RUN ulimit -n 1024
#=========================
# Environment Variables
# - please override those while starting the docker container or in an extended container
#=========================
ENV LDAP_ROOT_ORGANISATION Homelab
ENV LDAP_ROOT_DOMAIN home.lab
ENV LDAP_ROOT_PASSWORD YOURAWESOMEPASSWORDHERE

#=========================
# Updating the docker to latest & installing slapd and deps
#=========================
RUN apt-get -y update && apt-get -y upgrade
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y install slapd ldap-utils ldapscripts openssl dos2unix schema2ldif

#=========================
# Clean the container
#=========================
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*
RUN rm -rf /var/tmp/*
#=========================
# Expose Ports
# 389 = ldap port
# 636 = ldaps port
# - keep in mind those ports are open and annonced to public access
# - if you host firewall doesnt block those off - your fresh ldap may get used
#=========================
EXPOSE 389
EXPOSE 636

#=========================
# Add users ou to tree
# - copy the schema files to container
#=========================
COPY ldap_files/base/ldif/00_addAttributes.ldif /root/base/addAttributes.ldif
COPY ldap_files/base/ldif/00_inetOrgPerson.ldif /root/base/inetOrgPerson.ldif
COPY ldap_files/base/ldif/00_addUsersOu.ldif /root/base/addUsersOu.ldif
COPY ldap_files/base/ldif/00_addGroupOu.ldif /root/base/addGroupOu.ldif

#=========================
# Copy User and Group ldif files
#=========================
COPY ldap_files/groups /root/groups
COPY ldap_files/users /root/users
COPY ldap_files/user_groups /root/user_groups
COPY ldap_files/serviceuser /root/serivceuser

#=========================
# Creating basic directories for later usage
# - this also fixes the run script for CRLF issues
#=========================
RUN mkdir -p /etc/service/slapd
COPY container_start.sh /etc/service/slapd/run
RUN dos2unix /etc/service/slapd/run

ENTRYPOINT ["/bin/bash","/etc/service/slapd/run"]