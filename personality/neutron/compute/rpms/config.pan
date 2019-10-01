unique template personality/neutron/compute/rpms/config;

# Include some useful RPMs
include 'defaults/openstack/rpms';

prefix '/software/packages';
'{openstack-neutron}' ?= dict();
'{ebtables}' ?= dict();
'{ipset}' ?= dict();
