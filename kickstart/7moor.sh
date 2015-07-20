#!/bin/bash

if  [ ! -h /dev/cdrom  ];then
echo "sorry ,the cdrom is not exist "
exit 1
fi

mount /dev/cdrom  /media/cdrom

#		install  some software

alias yumlocal="yum --disablerepo=\* --enablerepo=c6-media"	
yumlocal  -y install  tree ftp sysstat nc perl-libxml-perl dos2unix ipmitool perl-Archive-Zip minicom lrzsz iotop telnet ant binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc glibc-common glibc-devel glibc-headers libaio  libaio-devel libgcc   libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel libXp gcc  bison  openssl-devel rpm-build speex ncurses-devel net-snmp net-snmp-devel net-snmp-libs net-snmp-utils  openssl098e-0.9.8e-17.el6.centos.2.x86_64 crypto-utils libcurl-devel libss libcmpiCppImpl0 libwsman1 openwsman-client sblim-sfcc sblim-sfcb openwsman-server


#		chkconfig some server
for s in `chkconfig --list |egrep "3:on|5:on"|awk '{print $1}'`;do chkconfig --level 35 $s off ;done	
for s in crond network syslog  sshd rpcbind snmpd ntpd ;do chkconfig --level 35 $s on ;done 

# 		disable selinux
sed -i 's/\=enforcing/\=disabled/' /etc/sysconfig/selinux	
sed -i 's/\=enforcing/\=disabled/' /etc/selinux/config	
sed -i 's/id\:5/id\:3/' /etc/inittab

#		file limits
echo  "* soft nofile 65000" >> /etc/security/limits.conf	
echo  "* hard nofile 65535" >> /etc/security/limits.conf	
echo "ulimit -n 65535"  >> /etc/rc.local


#		useadd groupadd
groupadd -g 801 sa	
useradd -g sa -u 803 monitor	
useradd -g sa -u 804 caizb	
useradd -g sa -u 805 zhangyang	
useradd -g sa -u 806 chenguang	
useradd -g sa -u 807 wangdx	
useradd -g sa -u 808 wangxb	
useradd -g sa -u 809 fengxf	
useradd -g sa -u 810 gujj	
useradd -g sa -u 811 zhaoxz	
useradd -g sa -u 812 wangwh	
useradd -g sa -u 813 huangzhuo
useradd -g sa -u 888 hanshengzhao

#		sudo file

echo "monitor     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "caizb     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "zhangyang     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "chenguang     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "wangdx     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "wangxb     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "fengxf     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "gujj     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "zhaoxz     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "wangwh     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers	
echo "huangzhuo     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers
echo "hanshengzhao     ALL=(ALL)     NOPASSWD: ALL">>/etc/sudoers

#		set passwd for user
echo  "Awe24dz6663c"|passwd monitor  --stdin 	
echo  "b5bbhsds8ooe"|passwd caizb  --stdin	
echo  "Mx42aazs6xsd"|passwd zhangyang  --stdin	
echo  "bvff334f3x5ids"|passwd chenguang  --stdin	
echo  "azcv6f3wWkj34"|passwd wangdx  --stdin	
echo  "brt@zdf5rXdws"|passwd wangxb  --stdin	
echo  "Hksmdjkd&4kr"|passwd fengxf  --stdin	
echo  "sdfkjB(kdm34fs"|passwd gujj  --stdin	
echo  "kfjfu#knfj9msGk"|passwd zhaoxz  --stdin
echo  "hanshengzhao"|passwd hanshengzhao --stdin

# 		set sshd file
echo "Port 65022">>/etc/ssh/sshd_config	

echo "PermitRootLogin no">>/etc/ssh/sshd_config	
sed -i '/PermitRootLogin yes/d' /etc/ssh/sshd_config 
echo "UseDNS no">>/etc/ssh/sshd_config	
echo "ClientAliveInterval  3600" >> /etc/ssh/sshd_config	
chkconfig --level 35 iptables off ;/etc/init.d/iptables stop	


#		snmp
sed -i 's/com2sec notConfigUser  default       public/com2sec notConfigUser  127.0.0.1       public/g' /etc/snmp/snmpd.conf	
sed -i 's/^access  notConfigGroup ""      any       noauth    exact/access  notConfigGroup ""      any       noauth    exact  mib2  none  none/g' /etc/snmp/snmpd.conf	
sed -i 's/\#view mib2   included  .iso.org.dod.internet.mgmt.mib-2 fc/view mib2   included  .iso.org.dod.internet.mgmt.mib-2 fc/' /etc/snmp/snmpd.conf	
sed -i 's/OPTIONS="-LS0-6d -Lf \/dev\/null -p \/var\/run\/snmpd.pid"/OPTIONS="-LS 4 d -p \/var\/run\/snmpd.pid -a"/g' /etc/init.d/snmpd 	

#		install nagios 
/usr/sbin/adduser nagios -M -s /sbin/nologin -u 1081
mkdir -p /tools/nagios && cd /tools
read -p "Enter The path .That can download nagios.zip" D_path
wget $D_path/nagios.zip
if [ $? -ne 0 ];then
"your enter is error"
exit
fi
unzip nagios.zip
	tar zxf nagios-plugins-1.4.16.tar.gz && cd nagios-plugins-1.4.16 && ./configure --with-nagios-user=nagios --with-nagios-group=nagios --enable-perl-modules && make && make install && cd ../	

tar zxvf nrpe-2.12.tar.gz && cd nrpe-2.12 && ./configure && make all && make install-plugin && make install-daemon && make install-daemon-config && cd ..	
tar zxvf Params-Validate-0.91.tar.gz && cd Params-Validate-0.91 && perl Makefile.PL && make && make install && cd ..	
tar zxvf Class-Accessor-0.31.tar.gz && cd Class-Accessor-0.31 && perl Makefile.PL && make && make install && cd .. 	
tar zxvf Config-Tiny-2.12.tar.gz && cd Config-Tiny-2.12 && perl Makefile.PL && make && make install && cd ..	
tar zxvf Math-Calc-Units-1.07.tar.gz && cd Math-Calc-Units-1.07 && perl Makefile.PL && make && make install && cd .. 	
tar zxvf Regexp-Common-2010010201.tar.gz && cd Regexp-Common-2010010201 && perl Makefile.PL && make && make install && cd ..	
tar zxvf Nagios-Plugin-0.34.tar.gz && cd Nagios-Plugin-0.34 && perl Makefile.PL && make && make install && cd ..	

cd /tools/nagios	
cp check_memory.pl check_iostat check_file_des check_netstat check_traffic.sh /usr/local/nagios/libexec	
chmod 755 /usr/local/nagios/libexec/*	
dos2unix /usr/local/nagios/libexec/check_memory.pl	
dos2unix /usr/local/nagios/libexec/check_iostat	
mkdir -p /var/tmp/nagios && chown -R nagios.nagios /var/tmp/nagios	

	sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=112.124.63.92/g' /usr/local/nagios/etc/nrpe.cfg

sed -i '199,203d' /usr/local/nagios/etc/nrpe.cfg
cat >> /usr/local/nagios/etc/nrpe.cfg << CRM											
command[check_load]=/usr/local/nagios/libexec/check_load -w 9,7,5 -c 50,30,15		
CRM	


cat >> /usr/local/nagios/etc/nrpe.cfg << CRM																																										
command[check_mem]=/usr/local/nagios/libexec/check_memory.pl -w 10% 																																			
command[check_disk_/]=/usr/local/nagios/libexec/check_disk -W 50% -w 20% -c 10% -E / 																														
command[check_disk_/var]=/usr/local/nagios/libexec/check_disk -W 50% -w 20% -c 10% -E /var																													
command[check_disk_/var/spool/asterisk]=/usr/local/nagios/libexec/check_disk -W 50% -w 20% -c 10% -E /var/spool/asterisk																						
command[check_disk_/data]=/usr/local/nagios/libexec/check_disk -W 50% -w 20% -c 10% -E /data																												
command[check_disk_/data2]=/usr/local/nagios/libexec/check_disk -W 50% -w 20% -c 10% -E /data2																												
command[check_disk_/dev/shm]=/usr/local/nagios/libexec/check_disk -W 50% -w 75% -c 50% -E /dev/shm																											
command[check_swap]=/usr/local/nagios/libexec/check_swap  -w 60% -c 60% 	
command[check_iostat]=/usr/local/nagios/libexec/check_iostat -w 6 -c 10	
command[check_users]=/usr/local/nagios/libexec/check_users -w 1 -c 10	
command[check_procs]=/usr/local/nagios/libexec/check_procs -w 300	
command[check_file_des]=/usr/local/nagios/libexec/check_file_des -c 20000	
command[check_net_num]=/usr/local/nagios/libexec/check_netstat -c 30000	
command[check_traffic-p3p1]=/usr/local/nagios/libexec/check_traffic.sh -V 2c -C public -H 127.0.0.1 -I \`ip add |grep ": p3p1:"|cut -d: -f1\` -w 10000,20000 -c 20000,30000 -M -B	
command[check_traffic-p3p2]=/usr/local/nagios/libexec/check_traffic.sh -V 2c -C public -H 127.0.0.1 -I \`ip add |grep ": p3p2:"|cut -d: -f1\` -w 10000,20000 -c 20000,30000 -M -B	
command[check_traffic-p4p1]=/usr/local/nagios/libexec/check_traffic.sh -V 2c -C public -H 127.0.0.1 -I \`ip add |grep ": p4p1:"|cut -d: -f1\` -w 10000,20000 -c 20000,30000 -M -B	
command[check_traffic-p4p2]=/usr/local/nagios/libexec/check_traffic.sh -V 2c -C public -H 127.0.0.1 -I \`ip add |grep ": p4p2:"|cut -d: -f1\` -w 10000,20000 -c 20000,30000 -M -B	
command[check_traffic-em1]=/usr/local/nagios/libexec/check_traffic.sh -V 2c -C public -H 127.0.0.1 -I \`ip add |grep ": em1:"|cut -d: -f1\` -w 10000,20000 -c 20000,30000 -M -B	
command[check_traffic-bond0]=/usr/local/nagios/libexec/check_traffic.sh -V 2c -C public -H 127.0.0.1 -I \`ip add |grep ": bond0:"|cut -d: -f1\` -w 10000,20000 -c 20000,30000 -M -B	
command[check_traffic-bond1]=/usr/local/nagios/libexec/check_traffic.sh -V 2c -C public -H 127.0.0.1 -I \`ip add |grep ": bond1:"|cut -d: -f1\` -w 10000,20000 -c 20000,30000 -M -B	
CRM	


echo "*/5 * * * * root /usr/sbin/lsof -n |wc -l > /usr/local/nagios/libexec/file_des" >>/etc/crontab

echo "/etc/init.d/nrpe start" >> /etc/rc.local

cat >> /etc/init.d/nrpe << CRM	
#!/bin/bash	
#20120406	
case \${1} in 	
start)	
       /usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d	
       echo  " Start nrpe     [ok] "	
;;	
stop)	
       kill -9 \`cat /var/run/nrpe.pid\`	
       echo  " Stop nrpe     [ok] "	
;;	
restart)	
       \${0} stop && \${0} start	
       echo  " Restart nrpe     [ok] "	
;;	
*)	
       echo  "Usage: \${0} {start|stop|restart}"	
;;	
esac	
CRM	
chmod 755 /etc/init.d/nrpe	

wget $D_path/iftop-1.0-0.1.pre2.el6.x86_64.rpm 
rpm -ivh iftop-1.0-0.1.pre2.el6.x86_64.rpm 

echo "koalabin1981" |passwd  root --stdin

	








