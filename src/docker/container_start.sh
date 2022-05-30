#!/bin/bash
# Startup and setup script for the slapd container
# A lot of comments are added to either help new ppl to read that script or be a mind-bridge for every one else :-)
#=================================

# exit the script immdiately if something returns not null
set -o errexit

status () {
  # shellcheck disable=SC2145
  echo "---> ${@}" >&2
}

# check if this container was stopped and now is started again

if [ -e /root/setup.done ]; then
    echo "This container was stopped. No further action needed!"
else
    # first start
    echo "Fresh Container. Setting it up!"
    # set bash vars from environment vars
    rootPassword=${LDAP_ROOT_PASSWORD}
    rootDomain=${LDAP_ROOT_DOMAIN}
    rootOrg=${LDAP_ROOT_ORGANISATION}
    echo "Setting up slapd environment for $rootOrg under $rootDomain"

    # setting up the slapd
    echo "slapd slapd/internal/generated_adminpw password ${rootPassword}" | debconf-set-selections
    echo "slapd slapd/internal/adminpw password ${rootPassword}" | debconf-set-selections
    echo "slapd slapd/password2 password ${rootPassword}" | debconf-set-selections
    echo "slapd slapd/password1 password ${rootPassword}" | debconf-set-selections
    echo "slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION" | debconf-set-selections
    echo "slapd slapd/domain string ${rootDomain}" | debconf-set-selections
    echo "slapd shared/organization string ${rootOrg}" | debconf-set-selections
    echo "slapd slapd/backend string HDB" | debconf-set-selections
    echo "slapd slapd/purge_database boolean true" | debconf-set-selections
    echo "slapd slapd/move_old_database boolean true" | debconf-set-selections
    echo "slapd slapd/allow_ldap_v2 boolean false" | debconf-set-selections
    echo "slapd slapd/no_configuration boolean false" | debconf-set-selections
    echo "slapd slapd/dump_database select when needed" | debconf-set-selections

    # reconfigure the slapd
    dpkg-reconfigure -f noninteractive slapd

    # touch a file so the container knows it was started already
    touch /root/setup.done
fi

#keep a connection alive
sh -c '/usr/sbin/slapd -h "ldap://0.0.0.0 ldaps://0.0.0.0 ldapi:///" -d 0' &
sleep 10

set -x
sh -c 'ldapadd -x -D "cn=admin,dc=home,dc=lab" -w ${LDAP_ROOT_PASSWORD} -H ldapi:/// -f /root/base/addUsersOu.ldif'
sh -c 'ldapadd -x -D "cn=admin,dc=home,dc=lab" -w ${LDAP_ROOT_PASSWORD} -H ldapi:/// -f /root/base/addGroupOu.ldif'

sh -c 'ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/base/addAttributes.ldif'
sh -c 'ldapmodify -Y EXTERNAL -H ldapi:/// -f /root/base/inetOrgPerson.ldif'

#add all groups
find /root/01_groups -name "*.ldif" -exec sh -c "ldapmodify -x -D "cn=admin,dc=home,dc=lab" -w ${LDAP_ROOT_PASSWORD} -H ldapi:/// -f {}" \;
#add all users
find /root/02_users -name "*.ldif" -exec sh -c "ldapmodify -x -D "cn=admin,dc=home,dc=lab" -w ${LDAP_ROOT_PASSWORD} -H ldapi:/// -f {}" \;
#add all users to groups
find /root/03_user_groups -name "*.ldif" -exec sh -c "ldapmodify -x -D "cn=admin,dc=home,dc=lab" -w ${LDAP_ROOT_PASSWORD} -H ldapi:/// -f {}" \;
#add all service-users
find /root/04_technical_users -name "*.ldif" -exec sh -c "ldapmodify -x -D "cn=admin,dc=home,dc=lab" -w ${LDAP_ROOT_PASSWORD} -H ldapi:/// -f {}" \;
# log everything started
echo "slapd started"
tail -f /dev/null