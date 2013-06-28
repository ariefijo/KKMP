#!/bin/bash

#DEFINE VARIABLES
proccess=1
knock_conf="CONFIG"
knock_help="README"
knock_status="STATUS"
knock_firewall="/etc/iptables.cfg"
dir_start="/etc/rc.local"

#DEFINE FUNCTIONS
function app_banner(){
  clear
	echo "############################################"
	echo "############################################"
	echo "#####                                  #####"
	echo "#####      KNOCK-KNOCK MY PORTS        #####"
	echo "#####                                  #####"
	echo "############################################"
	echo "############################################"
	echo "#####                                  #####"
	echo "##### Author   : Moh. Nazar Agliyono   #####"
	echo "##### Purpose  : Penulisan Ilmiah S1   #####"
	echo "##### Major    : Teknik Informatika    #####"
	echo "##### Institue : Universitas Gunadarma #####"
	echo "#####                                  #####"
	echo "############################################"
	echo "############################################"
}
function pause_now(){
	echo -n ">> Press [enter] to continue.."; read z;
}
function is_status(){
	if [ $1 -eq 1 ]; then
                statusKnocking="[\033[32mRUNNING\033[0m]"
        else
                statusKnocking="[\033[35mUNUSED\033[0m]"
        fi
	echo -e $statusKnocking
}
function start_rules(){
	source $1
	iptables -F
	iptables -X

	iptables -P INPUT DROP
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT

	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	#iptables -A INPUT -p icmp --icmp-type any -j ACCEPT

	iptables -N MASUK
	iptables -A MASUK -m recent --name KLOG1 --set

	iptables -N FUNGSI1
	iptables -A FUNGSI1 -m recent --name KLOG1 --remove
	iptables -A FUNGSI1 -m recent --name KLOG2 --set

	iptables -N FUNGSI2
	iptables -A FUNGSI2 -m recent --name KLOG2 --remove
	iptables -A FUNGSI2 -m recent --name KLOG3 --set

	iptables -N FUNGSI3
	iptables -A FUNGSI3 -m recent --name KLOG3 --remove
	iptables -A FUNGSI3 -m recent --name KLOG4 --set

	iptables -N FUNGSI_LOCK
	iptables -A FUNGSI_LOCK -m recent --name KLOG1 --remove
	iptables -A FUNGSI_LOCK -m recent --name KLOG2 --remove
	iptables -A FUNGSI_LOCK -m recent --name KLOG3 --remove
	iptables -A FUNGSI_LOCK -m recent --name KLOG4 --remove

	iptables -N FUNGSI_UNLOCK
	iptables -A FUNGSI_UNLOCK -m recent --name KLOG4 --remove
	iptables -A FUNGSI_UNLOCK -m recent --name KLOG4 --set
	iptables -A FUNGSI_UNLOCK -m recent --name KLOG4 --set


	iptables -A INPUT -p tcp --dport $PORT_1 -m recent --rcheck --name KLOG4 --hitcount 2 -j MASUK
	iptables -A INPUT -p tcp --dport $PORT_2 -m recent --rcheck --name KLOG1 --hitcount 1 -j FUNGSI1
	iptables -A INPUT -p tcp --dport $PORT_3 -m recent --rcheck --name KLOG2 --hitcount 1 -j FUNGSI2
	iptables -A INPUT -p tcp --dport $PORT_4 -m recent --rcheck --name KLOG3 --hitcount 1 -j FUNGSI3

	iptables -A INPUT -p tcp --dport $OPEN_PORT -m recent --rcheck --seconds $INTERVAL_TIME --name KLOG4 --hitcount 3 -j ACCEPT

	iptables -A INPUT -p tcp --dport $PORT_LOCK -j FUNGSI_LOCK
	iptables -A INPUT -p tcp --dport $PORT_UNLOCK -j FUNGSI_UNLOCK
}
function stop_rules(){
	iptables -F
	iptables -X
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
}
function view_logs(){
	OK="[\033[32mOK\033[0m]"
	SUCCESS="[\033[36mSUCCESS\033[0m]"
	echo -e ">> Reading logs.. $OK"
	echo -e ">> >> First Knock Log.. $OK"
	echo ">> >> "; cat /proc/net/ipt_recent/KLOG1
	echo -e ">> >> Second Knock Log.. $OK"
        echo ">> >> "; cat /proc/net/ipt_recent/KLOG2
	echo -e ">> >> Third Knock Log.. $OK"
        echo ">> >> "; cat /proc/net/ipt_recent/KLOG3
	echo -e ">> >> Fourth Knock Log.. $OK"
    	echo ">> >> "; cat /proc/net/ipt_recent/KLOG4
	echo -e ">> Monitoring complete.. $SUCCESS"
}

#CHECKING CONFIGURATION'S FILES
	#Colouring Status
	OK="[\033[32mOK\033[0m]"
	FAIL="[\033[31mFAIL\033[0m]"
	SUCCESS="[\033[36mSUCCESS\033[0m]"
clear
source $knock_status
app_banner
echo ">> Reading Configurations.."
if [ -e $knock_conf ]; then
	echo -e ">> >> Checking $knock_conf complete.. $OK"
else
	echo -e ">> >> File $knock_conf doesn't exist! $FAIL"
        proccess=0
fi
if [ -e $knock_help ]; then
       	echo -e ">> >> Checking $knock_help complete.. $OK"
else
        echo -e ">> >> File $knock_help doesn't exist! $FAIL"
        proccess=0
fi
if [ -e $knock_status ]; then
        echo -e ">> >> Checking $knock_status complete.. $OK"
else
        echo -e ">> >> File $knock_status doesn't exist! $FAIL"
        proccess=0
fi
if [ $knocking -eq 1 ]; then
        echo -e ">> >> Checking KNOCKING complete.. $OK"
else
        echo -e ">> >> Clearing FIREWALL $OK"
        stop_rules
fi
echo -e ">> Checking complete.. $SUCCESS"
pause_now

#BODY PROCCESS
echo "iptables-restore -c $knock_firewall" > $dir_start
echo "exit 0" >> $dir_start
clear
while [ $proccess == 1 ]
do
	#IMPORTING STATUS KNOCKING
	source $knock_status
	clear
	echo "[[===========================]]"
	echo "||    KNOCK-KNOCK MY PORT    ||"
	echo "[[===========================]]"
	echo "||                           ||"
	echo "|| 1. Start Knock Rules      ||"
	echo "|| 2. Restart Knock Rules    ||"
	echo "|| 3. Stop Knock Rules       ||"
	echo "|| 4. Config Knock Rules     ||"
	echo "|| 5. View Knock Logs        ||"
    echo "|| 6. View Firewall Rules    ||"
	echo "|| 7. Help                   ||"
	echo "|| 8. Quit                   ||"
	echo "[[===========================]]"
	echo -n ">> KNOCK STATUS : "; is_status $knocking
	echo -n ">> OPTION - "; read option

	case $option in
	1)
		if [ $knocking -eq 0 ]; then
			echo -e ">> Knocking is starting.. $OK"
				start_rules $knock_conf
					echo -e ">> >> Creating rules.. $OK"
				echo "knocking=1" > $knock_status
					echo -e ">> >> Updating status.. $OK"
				iptables-save > $knock_firewall
					echo -e ">> >> Saving firewall.. $OK"
			echo -e ">> Starting complete.. $SUCCESS"
		else
			echo -e ">> Knocking is already started! $FAIL"
		fi
		pause_now
	continue;;
	2)
		if [ $knocking -eq 1 ]; then
			echo -e ">> Knocking is restarting.. $OK"
				echo -e ">> >> Knocking is stopping.. $OK"
					stop_rules
					echo "knocking=0" > $knock_status
					echo -e ">> >> >> Stopping complete.. $OK"
				echo -e ">> >> Knocking is starting.. $OK"
					start_rules $knock_conf
					echo "knocking=1" > $knock_status
					echo -e ">> >> >> Starting complete.. $OK"
				echo -e ">> >> Firewall is updating.. $OK"
					iptables-save > $knock_firewall
					echo -e ">> >> >> Updating complete.. $OK"
				echo -e ">> Restarting complete.. $SUCCESS"
		else
			echo -e ">> Knocking hasn't started yet! $FAIL"
		fi
		pause_now
	continue;;
	3)
		if [ $knocking -eq 1 ]; then
			echo -e ">> Knocking is stopping.. $OK"
				stop_rules
					echo -e ">> >> Deleting rules.. $OK"
				echo "knocking=0" > $knock_status
					echo -e ">> >> updating status.. $OK"
				iptables-save > $knock_firewall
					echo -e ">> >> Saving firewall.. $OK"
			echo -e ">> Stopping complete.. $SUCCESS"
		else
			echo -e ">> Knocking is already stop! $FAIL"
		fi
		pause_now
	continue;;
	4)
		vim $knock_conf
	continue;;
	5)
		if [ $knocking -eq 1 ]; then
			view_logs
		else
			 echo -e ">> Knocking hasn't started yet! $FAIL"
		fi
		pause_now
	continue;;
	6)
		if [ $knocking -eq 1 ]; then
                        clear
		fi
		echo ">> Reading configurations.."
		iptables -nvL
		echo -e ">> Monitoring complete.. $SUCCESS"
		pause_now
	continue;;
	7)
		clear
		cat README
		pause_now
	continue;;
	8)
		app_banner
		proccess=0
		pause_now
		clear
	continue;;
	*)
		echo -e ">> Wrong answer! Please try again... $FAIL"
		pause_now
	continue;;
	esac

done
