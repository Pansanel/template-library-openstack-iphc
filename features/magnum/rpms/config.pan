unique template features/magnum/rpms/config;

# Include some useful RPMs
include 'defaults/openstack/rpms';

prefix '/software/packages';
'python-magnumclient' ?= dict();
'openstack-magnum-api' ?= dict();
'openstack-magnum-conductor' ?= dict();
