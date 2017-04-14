#!/bin/bash

# Usage: [OPTIONS] ./16.04.sh
#  - ansible_version: the ansible version to be installed

# Exit on any individual command failure.
set -e

ansible_version=${ansible_version:-"latest"}


apt-get -q update
apt-get install -q -y --no-install-recommends python-software-properties\
  software-properties-common rsyslog systemd systemd-cron sudo\
  python-setuptools build-essential libssl-dev libffi-dev \
  python-dev python-pip wget
rm -Rf /var/lib/apt/lists/*
rm -Rf /usr/share/doc
rm -Rf /usr/share/man
apt-get -q clean
sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

pip -q install --upgrade pip

if [ $ansible_version = "latest" ]; then
  pip install ansible
else
  pip install ansible==$ansible_version
fi

wget -O initctl_faker https://raw.githubusercontent.com/briandbecker/ansible-role-test-shims/master/config/ubuntu/initctl_faker
chmod +x initctl_faker
rm -fr /sbin/initctl
ln -s /initctl_faker /sbin/initctl



