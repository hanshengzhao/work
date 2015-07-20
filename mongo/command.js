use admin
db.runCommand({addshard:"replset1/192.168.3.17:27001,192.168.3.17:27011"})
db.runCommand({addshard:"replset2/192.168.3.17:27002,192.168.3.17:27022"})

printShardingStatus()
