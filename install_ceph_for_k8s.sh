#!/bin/bash
# Make sure to run this with sudo!!!
echo "Installing Ceph"
cd
pip3 install --user notario netaddr
wait
sudo pip3 uninstall ansible -y
sudo pip3 install ansible==2.7.12
mkdir ceph
cd ceph
git clone https://github.com/alta3/ceph-the-alta3-way.git
cd ceph-the-alta3-way
git checkout training_wheels
sleep 3
NUM="$(cut -d"-" -f2 <<< $HOSTNAME)"
echo $NUM

echo  "---
all:
  vars:
    student_number:            '$NUM'  #<- Make this your student number
    ansible_user:               student   
    monitor_address_block:      10.0.0.0/12
    public_network:             10.0.0.0/12
    ansible_python_interpreter: /usr/bin/python3
  children:
    clients:
      hosts:
        localhost
    mons:
      hosts:
        master1:
          ansible_host: k8s-{{ student_number }}-master-01.localdomain
        master2:
          ansible_host: k8s-{{ student_number }}-master-02.localdomain
        master3:
          ansible_host: k8s-{{ student_number }}-master-03.localdomain
    osds:
      hosts:
        node1:
          ansible_host: k8s-{{ student_number }}-node-01.localdomain
        node2:
          ansible_host: k8s-{{ student_number }}-node-02.localdomain
        node3:
          ansible_host: k8s-{{ student_number }}-node-03.localdomain
    mdss:
      hosts:
        node1:
          ansible_host: k8s-{{ student_number }}-node-01.localdomain" > hosts.yaml
echo "Starting to Install Ceph with Ansible"
sleep 3
ansible-playbook -i /home/student/ceph/ceph-the-alta3-way/hosts.yaml main.yml
sleep 3

echo "Initializing Ceph"
A="$(ls ~/fetch/)"
cd /home/student/fetch/$A/etc/ceph/
sudo cp ceph.client.admin.keyring /etc/ceph
cd ~
echo "Checking On Ceph Status"
ceph status
echo "Checking On Ceph Health"
ceph health
