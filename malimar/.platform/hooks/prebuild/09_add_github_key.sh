#!/usr/bin/env bash
set -xe

known_hosts_check_list=(
    github.com
    gitlab.com
    bitbucket.com
)

sudo touch /etc/ssh/ssh_known_hosts
for host in "${known_hosts_check_list[@]}"; do
    if grep -q $host /etc/ssh/ssh_known_hosts; then
        echo "$host already in global known hosts"
    else
        sudo ssh-keyscan -H $host >> /etc/ssh/ssh_known_hosts
        echo "Added $host to global known hosts"
    fi
done
