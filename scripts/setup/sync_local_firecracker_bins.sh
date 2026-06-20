#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

source "$DIR/setup.cfg"

if [ "${SYNC_LOCAL_FIRECRACKER_BINS}" != "true" ]; then
    exit 0
fi

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <node> [node...]"
    exit 1
fi

if [ ! -d "${LOCAL_VHIVE_BIN_DIR}" ]; then
    echo "LOCAL_VHIVE_BIN_DIR does not exist: ${LOCAL_VHIVE_BIN_DIR}"
    exit 1
fi

server_exec() {
    ssh -oStrictHostKeyChecking=no -p 22 "$1" "$2"
}

sync_node() {
    node=$1
    bins=(
        firecracker
        jailer
        firecracker-containerd
        containerd-shim-aws-firecracker
    )

    for bin in "${bins[@]}"
    do
        if [ ! -x "${LOCAL_VHIVE_BIN_DIR}/${bin}" ]; then
            echo "Missing executable local binary: ${LOCAL_VHIVE_BIN_DIR}/${bin}"
            exit 1
        fi
        rsync -e "ssh -oStrictHostKeyChecking=no -p 22" "${LOCAL_VHIVE_BIN_DIR}/${bin}" "${node}:/tmp/${bin}"
    done

    server_exec "$node" 'sudo install -m 0755 /tmp/firecracker /usr/local/bin/firecracker && sudo install -m 0755 /tmp/jailer /usr/local/bin/jailer && sudo install -m 0755 /tmp/firecracker-containerd /usr/local/bin/firecracker-containerd && sudo install -m 0755 /tmp/containerd-shim-aws-firecracker /usr/local/bin/containerd-shim-aws-firecracker'
    server_exec "$node" 'if [ -d ~/vhive/bin ]; then cp /tmp/firecracker ~/vhive/bin/firecracker && cp /tmp/jailer ~/vhive/bin/jailer && cp /tmp/firecracker-containerd ~/vhive/bin/firecracker-containerd && cp /tmp/containerd-shim-aws-firecracker ~/vhive/bin/containerd-shim-aws-firecracker; fi'
}

for node in "$@"
do
    sync_node "$node" &
done

wait
