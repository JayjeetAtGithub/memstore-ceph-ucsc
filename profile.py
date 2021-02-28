import geni.portal as portal
import geni.rspec.pg as pg

pc = portal.Context()
request = pc.makeRequestRSpec()

storage = request.RawPC("node1")
storage.addService(pg.Execute(shell="sh", command="sudo /local/repository/micro-osd.sh"))

client = request.RawPC("node0")
storage.addService(pg.Execute(shell="sh", command="sudo /local/repository/client.sh"))

link = request.Link(members=[client, storage])

pc.printRequestRSpec(request)
