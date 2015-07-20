
use admin
config = {_id:"replset2", members:[
{_id:0,host:"192.168.3.17:27002",priority:4},
{_id:1,host:"192.168.3.17:27022",priority:5},
{_id:2,host:"192.168.3.17:27222",arbiterOnly:true},
]
}
rs.initiate(config)
rs.status()
