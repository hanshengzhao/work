ip=`ifconfig   |grep -v 127| grep "inet addr" | awk '{print $2}'  | awk -F ":" '{print $2}'`

sed -e "s/192.168.3.15/$ip/g" command.js -i
cat /usr/local/mongodb-2.6.9/command.js | /usr/local/mongodb-2.6.9/bin/mongo $ip:27111/admin --shell




