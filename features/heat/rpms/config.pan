unique template features/heat/rpms/config;

# Include some useful RPMs
include 'defaults/openstack/rpms';

prefix '/software/packages';
'openstack-heat-api' ?= dict();
'openstack-heat-api-cfn' ?= dict();
'openstack-heat-engine' ?= dict();
'python-heatclient' ?= dict();
