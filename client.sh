#!/bin/bash
set -eux

# install dependencies
apt update
apt install -y ceph-common ceph-fuse

mkdir -p /mnt/cephfs
