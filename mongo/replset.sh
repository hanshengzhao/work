ip=`ifconfig   |grep -v 127| grep "inet addr" | awk '{print $2}'  | awk -F ":" '{print $2}'`


sed -e "s/192.168.3.15/$ip/g" *.js -i

cat /usr/local/mongodb-2.6.9/replset1.js | /usr/local/mongodb-2.6.9/bin/mongo $ip:27011 --shell



cat /usr/local/mongodb-2.6.9/replset2.js | /usr/local/mongodb-2.6.9/bin/mongo $ip:27022 --shell

