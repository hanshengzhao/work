#!/bin/bash
# asterisk config scripts
# created by hansz
# usage : ./config.sh  -s 0 -e 9 -n "bj.ali.2"
# install package is pbx.tar.gz 

# Variable definition
package=/tools/pbx
#ip=`curl ifconfig.me`
ip=`ifconfig   |grep -v 127| grep "inet addr" | awk '{print $2}'  | awk -F ":" '{print $2}'| tail -1`
mask=`ifconfig   |grep -v 127| grep "inet addr" | awk '{print $4}'  | awk -F ":" '{print $2}'| head -1`
#n_ip=$ip
 n_ip=`ifconfig   |grep -v 127| grep "inet addr" | awk '{print $2}'  | awk -F ":" '{print $2}'| head -1`
n_ip_network=`ipcalc -n $n_ip $mask | awk -F "=" '{print $2}'`
log=/var/log




# Error message
function error_exit(){
	echo "This script usage is "
	echo "-s The instance Start_num"
	echo "-e The instance End_num"
	echo "-n The instance name "
	exit 1 

}



# Arguments Choice
while getopts ":s:e:n:" arg 
do
	case $arg in
		s)
			Start_num=$OPTARG
			;;
		e)			
			End_num=$OPTARG
			;;
		n)
			Instance_name=$OPTARG
			;;

		?)
			echo "Unknow arguments"
			echo "config.sh  -s 0 -e 9 -n 'bj.ali.2' "
			exit 1
			;;
	esac
done 

# Parameter determination
if [[ -z $Instance_name ]];then
	echo -e "\e[31myou must appoint the instance name\e[0m"
	error_exit
fi
if [[ -z $Start_num ]] && [[ -z $End_num ]];then 
	echo -e "\e[32m The script will install 10 instance in this machine \e[0m"
	Start_num=0
	End_num=9
elif [[ $End_num -lt $Start_num ]];then
	echo -e "\e[31m The Start_num granter the  End_num\e[0m"
	error_exit
elif [[  $Start_num -lt 0 ]];then 
	echo -e "\e[31m The Start_num was error\e[0m" 
	error_exit
elif [[ $End_num -gt 9 ]];then
	echo -e "\e[31m The End_num was error\e[0m"
	error_exit

fi 

cd /tools
# File judgment and File decompression
[ -f pbx.tar.gz ] || echo -e "\e[32m Not found the pbx.tar.gz to install\e[0m" 
[ -f pbx.tar.gz ] || exit 1

mv pbx.tar.gz /tools/ 2>/dev/null ;cd /tools;
tar -zxmvf pbx.tar.gz  1>> $log/config_pbx.log 


# File modification
# Instance_name and instance port 
sleep 2
echo -e "\e[32m Start config asterisk file \e[0m"
cp -f $package/asterisk.ali.tar /etc/asterisk/ && cd /etc/asterisk/
tar -xmvf asterisk.ali.tar  1>> $log/config_pbx.log 
echo >/etc/asterisk/bj.ali.2.0/extensions_include.ael 
echo >/etc/asterisk/bj.ali.2.0/musiconhold_include.conf
echo >/etc/asterisk/bj.ali.2.0/queues_include.conf
echo >/etc/asterisk/bj.ali.2.0/sip_include.conf 
rm -rf /etc/asterisk/bj.ali.2.0/accounts/ 
sed -i "s/120.55.74.105/$ip/g" /etc/asterisk/*/*
sed -i "s/localnet=10.174.110.0\/255.255.255.0/localnet=$n_ip_network\/$mask/"  /etc/asterisk/*/*

for i  in 	`seq $Start_num $End_num`
do
cp bj.ali.2.0 $Instance_name.$i -R
sed -i "s/bj.ali.2.0/$Instance_name.$i/g"  $Instance_name.$i/*
sed -i "s/6060/606$i/g" $Instance_name.$i/*
sed -i "s/6030/603$i/g" $Instance_name.$i/*
done



# Create soft link
for s in `seq $Start_num $End_num` 
do 
mkdir -p /var/lib/asterisk/$Instance_name.$s 
ln -s /dev/shm/astdb/astdb$Instance_name.$s /var/lib/asterisk/$Instance_name.$s/astdb 1>> $log/config_pbx.log 
done




# mkdir 
for i in  /etc/asterisk/ /var/lib/asterisk/   /var/spool/asterisk/ /var/run/asterisk/  /var/log/asterisk/   
do 
	for j in `seq $Start_num $End_num` 
	do 
	mkdir -p  $i/$Instance_name.$j 
	mkdir -p /var/spool/asterisk/$Instance_name.$j/monitor
	done 
done

 mkdir -p  /etc/asterisk/gateway
 mkdir -p  /usr/lib/asterisk/modules
 mkdir -p  /var/lib/asterisk/gateway
 mkdir -p  /var/lib/asterisk
 mkdir -p  /var/lib/asterisk/agi-bin
 mkdir -p  /var/spool/asterisk/gateway
 mkdir -p  /var/run/asterisk/gateway
 mkdir -p  /var/log/asterisk/gateway


 # 	Add content to rc.local  /etc/profile /root/.bashrc
cat >>/etc/rc.local<<EOF
mkdir -p /dev/shm/astdb
EOF


for i in `seq $Start_num $End_num`
do
cat >>/etc/rc.local<<EOF
	touch /dev/shm/astdb/astdb$Instance_name.$i 
	mkdir -p /dev/shm/monitor$Instance_name.$i
	mkdir -p /var/run/asterisk/$Instance_name.$i 
	mkdir -p /var/spool/asterisk/$Instance_name.$i 
	/usr/sbin/asterisk -g -C /etc/asterisk/$Instance_name.$i/asterisk.conf 
	sleep 1 
	/opt/sipproxy/10$i/sipproxy.sh start
EOF
done
cat >>/etc/rc.local<<EOF
cp /usr/src/astdb/* /dev/shm/astdb/
mkdir -p /var/run/asterisk/gateway
/usr/sbin/asterisk -g -C /etc/asterisk/gateway/asterisk.conf
/opt/ass/ass.sh restart 
/opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf
/opt/asteriskGuard/monitor.sh start
/etc/init.d/nrpe start
EOF

echo "export LD_LIBRARY_PATH=/opt/kdxfServer" >> /etc/profile
for  i in `seq $Start_num $End_num`
do
cat >>/root/.bashrc<<EOF
	alias rasterisk$i='/usr/sbin/rasterisk -C /etc/asterisk/$Instance_name.$i/asterisk.conf'
EOF
done
echo "alias rasteriskg='/usr/sbin/rasterisk -C /etc/asterisk/gateway/asterisk.conf'" >>/root/.bashrc
source /root/.bashrc
echo -e "\e[32m asterisk is ok \e[0m"


#	Deployment ASS  configuration file	
echo -e "\e[32m Start config ass \e[0m"
sleep 3 
cd $package
tar -xvf  ass.tar -C /opt/ 1>> $log/config_pbx.log  ;cd /opt/ass/

#	modify  dialout.line  fileserver  district 
#ip=`curl ifconfig.me` & 
#sleep 30
#if [[ -z $ip ]];then
#	read -p "enter your ip address \n" ip
#fi
#
sed -i "s/dialout.line=10.1.12.100/dialout.line=$ip/" /opt/ass/server.conf
sed -i "s/106.39.108.82:8081/$ip/" /opt/ass/server.conf

 [[ $Instance_name =~ "bj" ]]&& sed -i 's/district=010/district=010/g' /opt/ass/server.conf
 [[ $Instance_name =~ "sh" ]]&& sed -i 's/district=010/district=021/g' /opt/ass/server.conf
 [[ $Instance_name =~ "gz" ]]&& sed -i 's/district=010/district=020/g' /opt/ass/server.conf
 dos2unix /opt/ass/server.conf 

# add the instace  
for i in  `seq $Start_num $End_num`
do
cat >>/opt/ass/server.conf<<EOF


[$Instance_name.$i]
host=127.0.0.1
port=603$i
user=dishui
password=7moorcom

EOF
done
echo "JAVA_HOME=/opt/java/" >/opt/ass/config-vars.sh 
echo -e "\e[32m ass is ok \e[0m"

#	Deployment kdxfServer configuration file	
echo -e "\e[32m Start config kdxfServer\e[0m"
sleep 3

cd $package
tar -xvf kdxfServer.tar.gz -C /opt/ 1>> $log/config_pbx.log 
cd /opt/kdxfServer/
echo "JAVA_HOME=/opt/java/" >/opt/kdxfServer/config-vars.sh 
echo -e "\e[32m kdxfServer is ok \e[0m"

# 	Deployment asteriskGuard configuration file	
echo -e "\e[32m Start config asteriskGuard \e[0m"
sleep 3
cd $package
tar -xvf asteriskGuard-proxy.tar -C /opt 1>> $log/config_pbx.log 
cd /opt/asteriskGuard/
sed -i "s/gz.ali.1/$Instance_name/g" asterisk.conf
dos2unix  asterisk.conf 
sed -i "/^mail.*$/s//&,yunwei@7moor.com/g" asterisk.conf
dos2unix  asterisk.conf 
echo -e "\e[32m asteriskGuard is ok \e[0m"

#	Deployment sipproxy configuration file	
echo -e "\e[32m Start config sipproxy \e[0m"
sleep 3
cd $package
tar -zxvf sipproxy.tar.gz -C /opt/ 1>> $log/config_pbx.log 
cd /opt/sipproxy
sed -i "s/211.151.35.101/$ip/g"  */* 

echo -e "\e[32m sipproxy is ok \e[0m"

#	Deployment nginx configuration file	
echo -e "\e[32m Start config nginx  \e[0m"
[ -d /opt/nginx  ] || echo "Sorry ,The nginx Not found in /opt ,Please config by yourself"
[ -d /opt/nginx  ] || exit 1 
sleep 3
cp -f  $package/nginx.conf  /opt/nginx/conf/nginx.conf 
/opt/nginx/sbin/nginx -t -c /opt/nginx/conf/nginx.conf

#sed -i '43,45d' /opt/nginx/conf/nginx.conf 
#sed -i "43 a 		access_log      off;\ 			\n 			location / {\n 			proxy_pass   http://127.0.0.1:8080;\n 	} \n 	       location /monitor {\n 	 root   /var/spool/asterisk/; \nindex  index.html index.htm;\n 	}	" /opt/nginx/conf/nginx.conf 
#echo "/opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf" >> /etc/rc.local
#echo "0 0 * * * /srv/scripts/nginx_cutlog.sh" >> /var/spool/cron/root



echo -e "\e[32m Start config the clear_asterisklog scripts\e[0m"
mkdir -p /srv/scripts
cat >> /srv/scripts/clear_asterisklog.sh  << CRM
#!/bin/bash
#
#this script  clear asterisk log
#history
#wangxb  2014-8-25 Version 1.0
ls /var/log/asterisk/*/full > /tmp/alog_file
ls /var/log/asterisk/*/*log >> /tmp/alog_file
ls /var/log/asterisk/*/message >> /tmp/alog_file
ls /var/log/asterisk/*/cdr-csv/Master.csv>> /tmp/alog_file
d=\`date +%u\`
list=\$(cat /tmp/alog_file)
for file in \$list
do
cp \${file}{,_\${d}}
> \${file}
done
/bin/rm /tmp/alog_file
CRM
																																																																																																																																																																																																																																																												
chmod a+x /srv/scripts/clear_asterisklog.sh
echo "0 1 * * * /srv/scripts/clear_asterisklog.sh" >>/var/spool/cron/root 
echo -e "\e[32m crontab  is  ok \e[0m "




[ -d /srv/scripts ] || mkdir /srv/scripts/
cat >>/srv/scripts/nginx_cutlog.sh<< EOF
#! /bin/bash
## Nginx 日志分割脚本
## by wangxb 
LOGS_PATH=/opt/nginx/logs
YESTERDAY=\`date -d "yesterday" +%Y-%m-%d\`
mv \${LOGS_PATH}/access.log \${LOGS_PATH}/access_\${YESTERDAY}.log
kill -USR1 \`cat /opt/nginx/logs/nginx.pid\`
EOF

chmod +x  /srv/scripts/nginx_cutlog.sh

echo -e "\e[32mDeployment complete\e[0m"
