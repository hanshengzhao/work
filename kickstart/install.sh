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
cat > /etc/dhcp/dhcpd.conf <<EOF
    # dhcpd.conf
    #
    # Sample configuration file for ISC dhcpd
    #
     
    allow booting;
    allow bootp;
     
    # A slightly different configuration for an internal subnet.
    subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.50 192.168.1.60;
    option domain-name-servers localhost;
    option domain-name "localhost";
    option routers 192.168.1.1;
    default-lease-time 600;
    max-lease-time 7200;
    filename "pxelinux.0";
    next-server 192.168.1.101;
    }



EOF


