unique template personality/neutron/controller/rpms/config;

prefix '/software/packages';

# Include some useful RPMs
include 'defaults/openstack/rpms';

prefix '/software/packages';
'{openstack-neutron}' ?= dict();
'{python-neutronclient}' ?= dict();
