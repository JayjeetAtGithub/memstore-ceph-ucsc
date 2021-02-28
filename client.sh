#!/bin/bash
set -eux

# install dependencies
apt update
apt install -y ceph-common ceph-fuse

# write the ceph config
cat >> /etc/ceph/ceph.conf <<EOF
[global]
osd crush chooseleaf type = 0
run dir = memstore-ceph/run
auth cluster required = none
auth service required = none
auth client required = none
osd pool default size = 1
[mon.0]
log file = memstore-ceph/log/mon.log
mon cluster log file = memstore-ceph/log/mon-cluster.log
mon data = memstore-ceph/mon
mon addr = 10.10.1.2
mon_allow_pool_delete = true
[osd.0]
log file = memstore-ceph/log/osd.log
osd data = memstore-ceph/osd
osd journal = memstore-ceph/osd.journal
osd journal size = 100
osd objectstore = memstore
osd class load list = *
EOF

# mount cephfs
mkdir -p /mnt/cephfs
sudo ceph-fuse -m 10.10.1.2:6789 /mnt/cephfs
