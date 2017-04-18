#!/bin/bash

# Usage: [OPTIONS] ./centos7.sh
#  - ansible_version: the ansible version to be installed

# Exit on any individual command failure.
set -e

ansible_version=${ansible_version:-"latest"}

yum -y update
yum clean all
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done)
rm -f /lib/systemd/system/multi-user.target.wants/*
rm -f /etc/systemd/system/*.wants/*
rm -f /lib/systemd/system/local-fs.target.wants/*
rm -f /lib/systemd/system/sockets.target.wants/*udev*
rm -f /lib/systemd/system/sockets.target.wants/*initctl*
rm -f /lib/systemd/system/basic.target.wants/*
rm -f /lib/systemd/system/anaconda.target.wants/*

yum makecache fast
yum -y install deltarpm epel-release initscripts openssl-devel gcc
yum -y install python-devel python-pip sudo which
yum -y update

pip -q install --upgrade pip

if [ $ansible_version = "latest" ]; then
  pip install ansible
else
  pip install ansible==$ansible_version
fi

# Disable requiretty
sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

#Install inventory file
mkdir /etc/ansible
echo -e "[local]" > /etc/ansible/hosts
echo -e "localhost ansible_connection=local" >> /etc/ansible/hosts
