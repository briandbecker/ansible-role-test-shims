# ansible-role-test-shims

Scripts for use in testing ansible roles with travisci.

Inspired from the following:
* https://www.jeffgeerling.com/blog/2016/how-i-test-ansible-configuration-on-7-different-oses-docker
* https://gist.github.com/geerlingguy/73ef1e5ee45d8694570f334be385e181

As well as geerlingguy's docker containers:
* https://github.com/geerlingguy/docker-ubuntu1604-ansible
* https://github.com/geerlingguy/docker-centos7-ansible

So why didn't I just use his containers?
* I wanted to control the ansible version.

So why didn't I fork his docker container repos?
* I didn't want to manage a bunch of simple docker container repos

But this is slower...
* Yes, it is admitedly slower to run though the build scripts on each test run but I have more control. I also partly did this just for the challenge.

# Requirements

1. Docker

# How to use

Run the test.sh file from within your ansible role. By default this will run the test/test.yml playbook on ubuntu 16.04 with the latest version of ansible.

```
my-ansible-role> ../ansible-role-test-shims/test.sh
```

You can pass in different playbooks to run.

```
my-ansible-role> env playbook=other_test.yml ../ansible-role-test-shims/test.sh
```

You can tell it not to cleanup the docker container when the test finishes.  This is helpful if you want to run additional tests on the container such as testing a connection to a service.  You will need to set the container_id so you can reference it in later tests.

```
my-ansible-role> env cleanup=false container_id=12345 ../ansible-role-test-shims/test.sh
```

# How to use with Travis

Put this in the .travis.yml

```
---
services:
  - docker

env:
  matrix:
    - DISTRO="ubuntu1604" PLAYBOOK="test.yml" ANSIBLE_VERSION="2.2.0"
    - DISTRO="ubuntu1604" PLAYBOOK="test.yml" ANSIBLE_VERSION="latest"
    - DISTRO="centos7" PLAYBOOK="test.yml" ANSIBLE_VERSION="2.2.0"
    - DISTRO="centos7" PLAYBOOK="test.yml" ANSIBLE_VERSION="latest"

script:

  # Download test shim.
  - wget -O ${PWD}/tests/test.sh https://raw.githubusercontent.com/briandbecker/ansible-role-test-shims/master/test.sh
  - chmod +x ${PWD}/tests/test.sh

  # Run tests.
  - env distro=$DISTRO ansible_version=$ANSIBLE_VERSION playbook=$PLAYBOOK ${PWD}/tests/test.sh

```
