"""Deploy a Single-node Ceph cluster backed by Memstore along with a Client

Instructions:
Copy the ceph config file from `/etc/ceph/ceph.conf` at node1 to the same path in node0.

To Mount the CephFS in the client node,
ceph-fuse --client_fs cephfs /mnt/cephfs
"""

import geni.portal as portal
import geni.rspec.pg as pg

pc = portal.Context()
request = pc.makeRequestRSpec()

storage = request.RawPC("node1")
storage.addService(pg.Execute(shell="sh", command="sudo /local/repository/micro-osd.sh"))

client = request.RawPC("node0")
client.addService(pg.Execute(shell="sh", command="sudo /local/repository/client.sh"))

link = request.Link(members=[client, storage])

pc.printRequestRSpec(request)
