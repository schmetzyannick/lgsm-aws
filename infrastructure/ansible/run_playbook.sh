#!/bin/sh

# remove file if exsits
rm -f /etc/ansible/inventory/hosts-replaced.ini
rm -f /tmp/host-contents/${GAME_NAME}/${GAME_NAME}server-copy.cfg

# Replace placeholder with actual IP from environment variable
cp /etc/ansible/inventory/hosts.ini /etc/ansible/inventory/hosts-replaced.ini
sed -i "s/AWS_LGSM_GAMESERVER_IP/${AWS_LGSM_GAMESERVER_IP}/g" /etc/ansible/inventory/hosts-replaced.ini
chmod 600 /root/.ssh/gameserver.pem

# Copy the cfg file
cp /tmp/host-contents/${GAME_NAME}/${GAME_NAME}server.cfg /tmp/host-contents/${GAME_NAME}/${GAME_NAME}server-copy.cfg
# for every env var that starts with GAME_PARAM_, extract the rest of the env var name 
# and replace the value in the cfg file
for var in `env | grep GAME_PARAM_ | awk -F "=" '{print $1}'`
do
    param_name=`echo $var | sed 's/GAME_PARAM_//g'`
    param_value=`printenv $var`
    sed -i "s/${param_name}=.*/${param_name}=${param_value}/g" /tmp/host-contents/${GAME_NAME}/${GAME_NAME}server-copy.cfg
done

# Run the Ansible playbook
ansible-playbook -i /etc/ansible/inventory/hosts-replaced.ini /etc/ansible/playbooks/lgsm.yml

# remove file if exsits
rm -f /etc/ansible/inventory/hosts-replaced.ini
rm -f /tmp/host-contents/${GAME_NAME}/${GAME_NAME}server-copy.cfg