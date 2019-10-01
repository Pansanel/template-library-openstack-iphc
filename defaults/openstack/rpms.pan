template defaults/openstack/rpms;

prefix '/software/packages';

# Some usefull RPMs that should be automaticaly added
'openstack-selinux' ?= dict();
'openstack-packstack' ?= dict();
'python-openstackclient' ?= dict();
'python-memcached' ?= dict();
'python-keystone' ?= dict();
'/software/packages' = {
#  pkg_repl('zeromq', '4.0.5-4.el7', 'x86_64');
#  pkg_repl('python-qpid-proton', '0.18.1-1.el7', 'x86_64');
#  pkg_repl('qpid-proton-c', '0.18.1-1.el7', 'x86_64');
  SELF;
};

