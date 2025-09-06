#! /bin/bash
source build.sh

# tail dev null to debug the container
#${cli_cmd} \
#    run \
#    --entrypoint "tail" \
#    -t $(echo "$REGISTRY/ldap-homelab:$TAG") -f /dev/null