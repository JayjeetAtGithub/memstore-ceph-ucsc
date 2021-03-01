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
storage.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD";

client = request.RawPC("node0")
client.addService(pg.Execute(shell="sh", command="sudo /local/repository/client.sh"))
client.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD";

link = request.Link(members=[client, storage])

pc.printRequestRSpec(request)
