#!/bin/bash
set -eux

# find the MON hostname
ips=$(hostname -I)
ip=`echo $ips | cut -d " " -f 2`
echo $ip

cluster_dir="memstore-ceph"
mkdir -p ${cluster_dir}/log

# install dependencies
apt update
apt install -y ceph-osd ceph-mon ceph-mds ceph-mgr ceph-common

# kill trailing daemons
pkill ceph-mon || true
pkill ceph-osd || true
rm -rf ${cluster_dir}

# create the global config
cat >> /etc/ceph/ceph.conf <<EOF
[global]
fsid = $(uuidgen)
osd crush chooseleaf type = 0
run dir = ${cluster_dir}/run
auth cluster required = none
auth service required = none
auth client required = none
osd pool default size = 1
EOF

# start a MON daemon
mkdir -p ${cluster_dir}/mon
cat >> /etc/ceph/ceph.conf <<EOF
[mon.0]
log file = ${cluster_dir}/log/mon.log
mon cluster log file = ${cluster_dir}/log/mon-cluster.log
mon data = ${cluster_dir}/mon
mon addr = ${ip}
mon_allow_pool_delete = true
EOF

ceph-mon --id 0 --mkfs --keyring /dev/null
touch ${cluster_dir}/mon/keyring
cp ${cluster_dir}/mon/keyring /etc/ceph/keyring
ceph-mon --id 0

# start a OSD daemon
mkdir -p ${cluster_dir}/osd
cat >> /etc/ceph/ceph.conf <<EOF
[osd.0]
log file = ${cluster_dir}/log/osd.log
osd data = ${cluster_dir}/osd
osd journal = ${cluster_dir}/osd.journal
osd journal size = 100
osd objectstore = memstore
osd class load list = *
EOF

OSD_ID=$(ceph osd create)
ceph osd crush add osd.${OSD_ID} 1 root=default host=localhost
ceph-osd --id ${OSD_ID} --mkjournal --mkfs
ceph-osd --id ${OSD_ID}

# start a MDS daemon
mkdir -p ${cluster_dir}/mds

ceph osd pool create cephfs_data 16
ceph osd pool create cephfs_metadata 16
ceph fs new cephfs cephfs_metadata cephfs_data

ceph-mds --id a
while [[ ! $(ceph mds stat | grep "up:active") ]]; do sleep 1; done

# start a MGR daemon
ceph-mgr --id 0

export CEPH_CONF="/etc/ceph/ceph.conf"
