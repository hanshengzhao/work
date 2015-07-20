# this is a scripts  to write some thing into mongodb
DB=$RANDOM
TB=$RANDOM
echo $DB
echo $TB
if [ "$#" -eq 1 ];then
i=10000
else
i=$2
fi
cat >data.js<<EOF

show dbs
use DB_$DB
for (var i=1;i<$i;i++){
db.tb_$TB.insert({"name":"name"+i})
}
EOF
ip=`ifconfig   |grep -v 127| grep "inet addr" | awk '{print $2}'  | awk -F ":" '{print $2}'`
cat data.js | /usr/local/mongodb-2.6.9/bin/mongo $ip:$1  --shell
sleep 2
