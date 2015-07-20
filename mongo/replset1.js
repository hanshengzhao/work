
use admin
config = {_id:"replset1", members:[
{_id:0,host:"192.168.3.17:27001",priority:4},
{_id:1,host:"192.168.3.17:27011",priority:5},
{_id:2,host:"192.168.3.17:27000",arbiterOnly:true},
]
}
rs.initiate(config)
rs.status()
