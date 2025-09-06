ARG REPOSITORY="docker.io"
FROM ${REPOSITORY}/library/debian:trixie-20250721-slim
MAINTAINER deB4SH <https://github.com/deB4SH>
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
COPY ldap_files/00_base/ldif/00_addAttributes.ldif /root/base/addAttributes.ldif
COPY ldap_files/00_base/ldif/00_inetOrgPerson.ldif /root/base/inetOrgPerson.ldif
COPY ldap_files/00_base/ldif/00_addUsersOu.ldif /root/base/addUsersOu.ldif
COPY ldap_files/00_base/ldif/00_addSvcUsersOu.ldif /root/base/addSvcUsersOu.ldif
COPY ldap_files/00_base/ldif/00_addGroupOu.ldif /root/base/addGroupOu.ldif

#=========================
# Copy User and Group ldif files
#=========================
COPY ldap_files/01_groups /root/01_groups
COPY ldap_files/02_users /root/02_users
COPY ldap_files/03_user_groups /root/03_user_groups
COPY ldap_files/04_technical_users /root/04_technical_users
COPY ldap_files/05_technical_user_groups /root/05_technical_user_groups

#=========================
# Creating basic directories for later usage
# - this also fixes the run script for CRLF issues
#=========================
RUN mkdir -p /etc/service/slapd
COPY container_start.sh /etc/service/slapd/run
RUN dos2unix /etc/service/slapd/run \
    && chmod +x /etc/service/slapd/run 

#=========================
# Disable policy-rc.d 
# - blocks restart and reconfigure of slapd while container is running
# - this is usually not the best idea to set the exit code to 0 
# - due to the fact that this is an debug/homelab container for testing with ldap it is fine
# - please consult policy-rc.d documentation for questions: https://people.debian.org/~hmh/invokerc.d-policyrc.d-specification.txt
#=========================
RUN echo exit 0 > /usr/sbin/policy-rc.d

ENTRYPOINT ["/bin/bash","/etc/service/slapd/run"]