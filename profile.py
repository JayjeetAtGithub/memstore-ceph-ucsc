import geni.portal as portal
import geni.rspec.pg as pg

pc = portal.Context()
request = pc.makeRequestRSpec()

client = request.RawPC("node0")
storage = request.RawPC("node1")
link = request.Link(members=[client, storage])

pc.printRequestRSpec(request)
