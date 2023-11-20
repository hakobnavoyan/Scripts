#!/bin/bash
for ip in $(cat /root/scripts/copysshid/ips)
do
	echo ${ip}
	sshpass -p 'Roo.1230' ssh-copy-id -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@${ip}
done
