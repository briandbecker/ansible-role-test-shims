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
* Yes, it is admitedly slower to run though the build scripts on each test 
