#!/bin/bash
#
# Ansible role test shim.
#
# Usage: [OPTIONS] ./tests/test.sh
#   - distro: a supported Docker distro version (default = "centos7")
#   - playbook: a playbook in the tests directory (default = "test.yml")
#   - cleanup: whether to remove the Docker container (default = true)
#   - container_id: the --name to set for the container (default = timestamp)
#   - ansible_version: the ansible version to test with

# Exit on any individual command failure.
set -e

# Pretty colors.
red='\033[0;31m'
green='\033[0;32m'
neutral='\033[0m'

repo="https://raw.githubusercontent.com/briandbecker/ansible-role-test-shims/master/"

timestamp=$(date +%s)

# Allow environment variables to override defaults.
distro=${distro:-"ubuntu1604"}
playbook=${playbook:-"test.yml"}
cleanup=${cleanup:-"true"}
container_id=${container_id:-$timestamp}
ansible_version=${ansible_version:-"latest"}

build_script="$repo/build/$distro.sh"

## Set up vars for Docker setup.
# Ubuntu 16.04
if [ $distro = 'ubuntu1604' ]; then
  docker="ubuntu:16.04"
  init="/lib/systemd/systemd"
  opts="--privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
# CentOS 7
elif [ $distro = 'centos7' ]; then
  docker="centos:7"
  init="/usr/lib/systemd/systemd"
  opts="--privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
else
  exit 1
fi

printf ${green}"Starting Docker container: $docker."${neutral}"\n"
docker pull $docker
docker run --detach --volume="$PWD":/etc/ansible/roles/role_under_test:rw --name $container_id $opts $docker $init

printf "\n"

printf ${green}"Fetch build  script from: $build_script"${neutral}"\n"
wget -O /tmp/build.sh $build_script
docker cp /tmp/build.sh $container_id:/build.sh
rm -f /tmp/build.sh
docker exec --tty $container_id env TERM=xterm chmod +x /build.sh
docker exec --tty $container_id env TERM=xterm ansible_version=$ansible_version ./build.sh

# Install requirements if `requirements.yml` is present.
if [ -f "$PWD/tests/requirements.yml" ]; then
  printf ${green}"Requirements file detected; installing dependencies."${neutral}"\n"
  docker exec --tty $container_id env TERM=xterm ansible-galaxy install -r /etc/ansible/roles/role_under_test/tests/requirements.yml
fi

printf "\n"

# Test Ansible syntax.
printf ${green}"Checking Ansible playbook syntax."${neutral}
docker exec --tty $container_id env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/$playbook --syntax-check

printf "\n"

# Run Ansible playbook.
printf ${green}"Running command: docker exec $container_id env TERM=xterm ansible-playbook /etc/ansible/roles/role_under_test/tests/$playbook"${neutral}
docker exec $container_id env TERM=xterm env ANSIBLE_FORCE_COLOR=1 ansible-playbook /etc/ansible/roles/role_under_test/tests/$playbook

# Run Ansible playbook again (idempotence test).
printf ${green}"Running playbook again: idempotence test"${neutral}
idempotence=$(mktemp)
docker exec $container_id ansible-playbook /etc/ansible/roles/role_under_test/tests/$playbook | tee -a $idempotence
tail $idempotence \
  | grep -q 'changed=0.*failed=0' \
  && (printf ${green}'Idempotence test: pass'${neutral}"\n") \
  || (printf ${red}'Idempotence test: fail'${neutral}"\n" && exit 1)

# Remove the Docker container (if configured).
if [ "$cleanup" = true ]; then
  printf "Removing Docker container...\n"
  docker rm -f $container_id
fi
