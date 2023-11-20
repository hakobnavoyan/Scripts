#!/bin/bash
ipconunt=0
IFS=$'\r\n' GLOBIGNORE='*' command eval  'ips=($(cat /root/scripts/copysshid/ips))'
for hostname in $(cat /root/scripts/sethostname/hostnames)
do
	echo ${hostname} ${ips[$ipconunt]}
    ssh root@${ips[$ipconunt]} "hostnamectl hostname ${hostname} && sudo systemctl restart systemd-hostnamed"
    ipconunt=$((ipconunt + 1))
done
