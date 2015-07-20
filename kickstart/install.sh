#This is a script
/bin/rpm -q tftp 
tftp_install_status=$?
/bin/rpm -q tftp-server
tftp_server_install_status=$?
/bin/rpm -q vsftpd
vsftpd_install_status=$?
/bin/rpm -q syslinux 
syslinux_install_status=$?
/bin/rpm -q nfs-utils
nfs_install_status=$?


/bin/rpm -q dhcp
dhcp_install_status=$?
/bin/rpm -q system-config-kickstart
kickstart_install_status=$?

/usr/bin/yum search tftp | grep tftp
yum_status=$?
if [ $yum_status -ne 0  ];then
	if [[ $tftp_install_status -ne 0  ]]&& [[ $dhcp_install_status -ne 0   ]] &&[[ $kickstart_install_status -ne 0  ]] && [[ $tftp_server_install_status -ne 0  ]] && [[ $vsftpd_install_status -ne 0  ]] && [[ $syslinux_install_status -ne 0 ]] && [[ $nfs_install_status -ne 0 ]]  ;then
	echo "sorry ,yum is not ok and the program must needed is required"
	exit 1
	else 
	echo "you have installed the program "
	fi

else
	echo "installing the program"
	/usr/bin/yum  install -y  tftp dhcp system-config-kickstart tftp-server vsftpd syslinux nfs-utils
fi

echo -e  "\e[31m Begining file config.....  \e[0m "
sed -i 's/disable= yes/disable= no/' /etc/xinetd.d/tftp
IP=`ifconfig   |grep -v 127| grep "inet addr" | awk '{print $2}'  | awk -F ":" '{print $2}'`
IP_NET=`echo $IP | awk -F '.' '{print $1"."$2"."$3}'`

cat > /etc/dhcp/dhcpd.conf <<EOF
# dhcpd.conf
# Sample configuration file created by hanshengzhao
 
allow booting;
allow bootp;
 
# A slightly different configuration for an internal subnet.
subnet $IP_NET.0 netmask 255.255.255.0 {
range $IP_NET.200 $IP_NET.230;
option domain-name-servers localhost;
option domain-name "localhost";
option routers $IP_NET.1;
default-lease-time 600;
max-lease-time 7200;
filename "pxelinux.0";
next-server $IP;
}
EOF

cp /usr/shard/syslinux/pxelinux.0 /var/lib/tftpboot
mount  /dev/cdrom  /media/cdrom
cp /media/cdrom/isolinux/*  /var/lib/tftpboot/
cd /var/lib/tftpboot/;mkdir pxelinux.cfg;cd pxelinux.cfg
cat >default<<EOF
    default linux
    #default vesamenu.c32
    prompt 1
    timeout 600
     
    display boot.msg
     
    menu background splash.jpg
    menu title Welcome to CentOS 6.5!
    menu color border 0 #ffffffff #00000000
    menu color sel 7 #ffffffff #ff000000
    menu color title 0 #ffffffff #00000000
    menu color tabmsg 0 #ffffffff #00000000
    menu color unsel 0 #ffffffff #00000000
    menu color hotsel 0 #ff000000 #ffffffff
    menu color hotkey 7 #ffffffff #ff000000
    menu color scrollbar 0 #ffffffff #00000000
     
    label linux
    menu label ^Install or upgrade an existing system
    menu default
    kernel vmlinuz
    append initrd=initrd.img ks=ftp://192.168.1.101/pub/ks.cfg
    label vesa
    menu label Install system with ^basic video driver
    kernel vmlinuz
    append initrd=initrd.img xdriver=vesa nomodeset
    label rescue
    menu label ^Rescue installed system
    kernel vmlinuz
    append initrd=initrd.img rescue
    label local
    menu label Boot from ^local drive
    localboot 0xffff
    label memtest86
    menu label ^Memory test
    kernel memtest
    append -

EOF


