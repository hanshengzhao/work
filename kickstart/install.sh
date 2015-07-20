#This is a script
/bin/rpm -q tftp 
tftp_install_status=$?
/bin/rpm -q dhcp
dhcp_install_status=$?
/bin/rpm -q system-config-kickstart
kickstart_install_status=$?

/usr/bin/yum search tftp | grep tftp
yum_status=$?
if [ $yum_status -ne 0  ];then
	if [[ $tftp_install_status -ne 0  ]]&& [[ $dhcp_install_status -ne 0   ]] &&[[ $kickstart_install_status -ne 0  ]] ;then
	echo "sorry ,yum is not ok and the program must needed is required"
	exit 1
	else 
	echo "you have installed the program "
	fi

else
	echo "installing the program"
	/usr/bin/yum  install -y  tftp dhcp system-config-kickstart
fi

echo -e  "\e[31m Begining file config.....  \e[0m "



