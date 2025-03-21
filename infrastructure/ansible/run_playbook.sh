#!/bin/sh

# remove file if exsits
rm -f /etc/ansible/inventory/hosts-replaced.ini

# Replace placeholder with actual IP from environment variable
cp /etc/ansible/inventory/hosts.ini /etc/ansible/inventory/hosts-replaced.ini
sed -i "s/AWS_LGSM_GAMESERVER_IP/${AWS_LGSM_GAMESERVER_IP}/g" /etc/ansible/inventory/hosts-replaced.ini
chmod 600 /root/.ssh/gameserver.pem

# Run the Ansible playbook
ansible-playbook -i /etc/ansible/inventory/hosts-replaced.ini /etc/ansible/playbooks/lgsm.yml

# remove file if exsits
rm -f /etc/ansible/inventory/hosts-replaced.ini
