#!/bin/bash

clear

echo "\e[1;33m*** CONFIGUREREN SYSTEEM\e[0m"
echo "\e[1;33m******\e[0m"
echo "\e[1;4;33m*** 1. STARTING SYSTEM UPDATES\e[0m"
echo "\e[1;33m******\e[0m"
echo "\e[1;33m*** 1.1 UPDATING.\e[0m"
apt update  > /dev/null 2>&1
echo "\e[1;33m*** 1.2 UPDGRADING. INDIEN NODIG KAN DIT EVEN DUREN\e[0m"
apt upgrade -y  > /dev/null 2>&1
echo "\e[1;33m*** 1.3 DIST-UPDGRADING. INDIEN NODIG KAN DIT EVEN DUREN\e[0m"
apt dist-upgrade -y  > /dev/null 2>&1
echo "\e[1;33m*** 1.4 VERWIJDEREN NIET MEER GEBRUIKTE BESTANDEN. INDIEN NODIG KAN HET EVEN DUREN ***\e[0m"
apt autoremove -y  > /dev/null 2>&1
echo "\e[1;33m******\e[0m"
echo "\e[1;4;33m*** 2. CONFIGURING SYSTEM SECURITY SETTINGS\e[0m"
echo "\e[1;33m*** \e[38;5;82m(Gebaseerd op de Azure security baseline voor linux systemen en\e[0m"
echo "\e[1;33m*** \e[38;5;82mCIS Ubuntu Linux 20.04 LTS Benchmark, v1.1.0)\e[0m"
echo "\e[1;33m*** 2.1 CRAMFS. \e[38;5;82m(1.1.1.1 Ensure mounting of cramfs filesystems is disabled)\e[0m"
cat >> /etc/modprobe.d/cramfs.conf <<EOL
install cramfs /bin/true
EOL
rmmod cramfs > /dev/null 2>&1
echo "\e[1;33m*** 2.2 FREEVXFS. \e[38;5;82m(1.1.1.2 Ensure mounting of freevxfs filesystems is disabled)\e[0m"
cat >> /etc/modprobe.d/freevxfs.conf <<EOL
install freevxfs /bin/true
EOL
rmmod freevxfs > /dev/null 2>&1
echo "\e[1;33m*** 2.3 JFFS. \e[38;5;82m(1.1.1.3 Ensure mounting of jffs2 filesystems is disabled)\e[0m"
cat >> /etc/modprobe.d/jffs2.conf <<EOL
install jffs2 /bin/true
EOL
rmmod jffs2 > /dev/null 2>&1
echo "\e[1;33m*** 2.4 HFS. \e[38;5;82m(1.1.1.4 Ensure mounting of hfs filesystems is disabled)\e[0m"
cat >> /etc/modprobe.d/hfs.conf <<EOL
install hfs /bin/true
EOL
rmmod hfs > /dev/null 2>&1
echo "\e[1;33m*** 2.5 HFSPLUS. \e[38;5;82m(1.1.1.5 Ensure mounting of hfsplus filesystems is disabled)\e[0m"
cat >> /etc/modprobe.d/hfsplus.conf <<EOL
install hfsplus /bin/true
EOL
rmmod hfsplus > /dev/null 2>&1
echo "\e[1;33m*** 2.6 BOOTLOADER. \e[38;5;82m(1.4.3 Ensure permissions on bootloader config are configured)\e[0m"
chown root:root /boot/grub/grub.cfg ;\
chmod u-wx,go-rwx /boot/grub/grub.cfg
echo "\e[1;33m*** 2.7 IPV4.conf. \e[38;5;82m(3.3.2 Ensure ICMP redirects are not accepted)\e[0m"
sed -i '50i net.ipv4.conf.all.secure_redirects = 0' /etc/sysctl.conf
sed -i '51i net.ipv4.conf.default.secure_redirects = 0' /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.secure_redirects=0 > /dev/null 2>&1
sysctl -w net.ipv4.conf.default.secure_redirects=0 > /dev/null 2>&1
sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1
echo "\e[1;33m*** 2.8 IPV4.conf. \e[38;5;82m(3.3.4 Ensure suspicious packets are logged)\e[0m"
sed -i 's/# net.ipv4.conf.all.log_martians\ =\ 1/net.ipv4.conf.all.log_martians\ =\ 1/g' /etc/sysctl.conf
sed -i '60i net.ipv4.conf.default.log_martians = 1' /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.log_martians=1 > /dev/null 2>&1
sysctl -w net.ipv4.conf.default.log_martians=1 > /dev/null 2>&1
sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1
echo "\e[1;33m*** 2.9 RP_FILTER. \e[38;5;82m(3.3.7 Ensure Reverse Path Filtering is enabled)\e[0m"
sed -i 's/net.ipv4.conf.default.rp_filter=2/net.ipv4.conf.default.rp_filter=1/g' /etc/sysctl.d/10-network-security.conf
sed -i 's/net.ipv4.conf.all.rp_filter=2/net.ipv4.conf.all.rp_filter=1/g' /etc/sysctl.d/10-network-security.conf
sysctl -w net.ipv4.conf.all.rp_filter=1 > /dev/null 2>&1
sysctl -w net.ipv4.conf.default.rp_filter=1 > /dev/null 2>&1
sysctl -w net.ipv4.route.flush=1 > /dev/null 2>&1
echo "\e[1;33m*** 2.10 AUDIT IDENTITY. \e[38;5;82m(4.1.4 Ensure events that modify user/group information are collected)\e[0m"
apt install auditd -y > /dev/null 2>&1 ;\
cat >> /etc/audit/rules.d/50-identity.rules <<EOL
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity
EOL
echo "\e[1;33m*** 2.11 AUDIT LOGIN. \e[38;5;82m(4.1.7 Ensure login and logout events are collected)\e[0m"
cat >> /etc/audit/rules.d/50-logins.rules <<EOL
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins
EOL
echo "\e[1;33m*** 2.12 CRONTAB. \e[38;5;82m(5.1.2 Ensure permissions on /etc/crontab are configured)\e[0m"
chown root:root /etc/crontab ;\
chmod og-rwx /etc/crontab
echo "\e[1;33m*** 2.13 CRON.HOURLY. \e[38;5;82m(5.1.3 Ensure permissions on /etc/cron.hourly are configured)\e[0m"
chown root:root /etc/cron.hourly/ ;\
chmod og-rwx /etc/cron.hourly/
echo "\e[1;33m*** 2.14 CRON.DAILY. \e[38;5;82m(5.1.4 Ensure permissions on /etc/cron.daily are configured)\e[0m"
chown root:root /etc/cron.daily/ ;\
chmod og-rwx /etc/cron.daily/
echo "\e[1;33m*** 2.15 CRON.WEEKLY. \e[38;5;82m(5.1.5 Ensure permissions on /etc/cron.weekly are configured)\e[0m"
chown root:root /etc/cron.weekly/ ;\
chmod og-rwx /etc/cron.weekly/
echo "\e[1;33m*** 2.16 CRON.MONTHLY. \e[38;5;82m(5.1.6 Ensure permissions on /etc/cron.monthly are configured)\e[0m"
chown root:root /etc/cron.monthly/ ;\
chmod og-rwx /etc/cron.monthly/
echo "\e[1;33m*** 2.17 CRON.D. \e[38;5;82m(5.1.7 Ensure permissions on /etc/cron.d are configured)\e[0m"
chown root:root /etc/cron.d/ ;\
chmod og-rwx /etc/cron.d/
echo "\e[1;33m*** 2.18 CRON.ALLOW. \e[38;5;82m(5.1.8 Ensure cron is restricted to authorized users)\e[0m"
echo "\e[1;33m***      \e[38;5;82mThe following user is added to cron.allow: sysadmin\e[0m"
FILE1=/etc/cron.deny
if [ -f "$FILE1" ]; then
	rm /etc/cron.deny
fi
FILE2=/etc/cron.allow
if [ ! -f "$FILE2" ]; then
	touch /etc/cron.allow
	chown root:root /etc/cron.allow 
	chmod g-wx,o-rwx /etc/cron.allow
	echo "sysadmin" > /etc/cron.allow
fi
echo "\e[1;33m*** 2.19 AT.ALLOW. \e[38;5;82m(5.1.9 Ensure at is restricted to authorized users)\e[0m"
echo "\e[1;33m***      \e[38;5;82mThe following user is added to at.allow: sysadmin\e[0m"
FILE3=/etc/at.deny
if [ -f "$FILE3" ]; then
	rm /etc/at.deny
fi
FILE4=/etc/at.allow
if [ ! -f "$FILE4" ]; then
	touch /etc/at.allow
	chown root:root /etc/at.allow 
	chmod g-wx,o-rwx /etc/at.allow
	echo "sysadmin" > /etc/at.allow
fi
echo "\e[1;33m*** 2.20 SUDOERS. \e[38;5;82m(5.2.2 Ensure sudo commands use pty en 5.2.3 Ensure sudo log file exists)\e[0m"
chmod 640 /etc/sudoers ;\
sed -i "12i Defaults	use_pty" /etc/sudoers ;\
sed -i "13i Defaults	logfile="/var/log/sudo.log"" /etc/sudoers ;\
chmod 440 /etc/sudoers
echo "\e[1;33m*** 2.21 SUDOERS. \e[38;5;82m(5.3.18 Ensure SSH warning banner is configured)\e[0m"
FILE5=/etc/issue
if [ -f "$FILE5" ]; then
	rm /etc/issue
fi
cat >> /etc/issue <<EOL

###############################################################
#                  This is a private server!                  #
#       All connections are monitored and recorded.           #
#  Disconnect IMMEDIATELY if you are not an authorized user!  #
###############################################################

EOL
FILE6=/etc/issue.net
if [ -f "$FILE6" ]; then
	rm /etc/issue.net
fi
cat >> /etc/issue.net <<EOL

###############################################################
#                  This is a private server!                  #
#       All connections are monitored and recorded.           #
#  Disconnect IMMEDIATELY if you are not an authorized user!  #
###############################################################

EOL
sed -i 's/#Banner none/Banner \/etc\/issue/g' /etc/ssh/sshd_config
systemctl restart sshd.service
echo "\e[1;33m*** 2.22 PASSWD-. \e[38;5;82m(6.1.3 Ensure permissions on /etc/passwd- are configured)\e[0m"
chown root:root /etc/passwd-
chmod u-x,go-wx /etc/passwd-
echo "\e[1;33m*** 2.23 GSHADOW. \e[38;5;82m(6.1.8 Ensure permissions on /etc/gshadow are configured)\e[0m"
chown root:shadow /etc/gshadow ;\
chmod u-x,g-wx,o-rwx /etc/gshadow
echo "\e[1;33m*** 2.24 GSHADOW-. \e[38;5;82m(6.1.9 Ensure permissions on /etc/gshadow- are configured)\e[0m"
chown root:shadow /etc/gshadow- ;\
chmod u-x,g-wx,o-rwx /etc/gshadow-
echo "\e[1;33m******\e[0m"
echo "\e[7;49;92mCONFIGURING SYSTEM SECURITY SETTINGS IS KLAAR\e[0m"
echo "\e[1;33m******\e[0m"
sleep 5
echo "\e[1;4;97mHET SYSTEEM MOET WORDEN HERSTART\e[0m"
echo "\e[1;4;97mGeef Y OM TE REBOOTEN, N OM HET LATER TE DOEN (Y or N)\e[0m"
read x
if [ "$x" = "y" ]; then
	echo "\e[1;4;97mHET SYSTEEM WORD HERSTART\e[0m"
	rm /root/.bash_history > /dev/null 2>&1
	history -c > /dev/null 2>&1
	reboot
fi
