#!/usr/bin/env sh

if [ "${VERBOSE:-0}" -eq 1 ]; then
/bin/docker-socket-firewall --target /mnt/in/docker.sock --host /mnt/out/docker.sock --policyDir /mnt/conf --verbose
else
/bin/docker-socket-firewall --target /mnt/in/docker.sock --host /mnt/out/docker.sock --policyDir /mnt/conf
fi

