unique template personality/neutron/network/rpms/config;

# Include some useful RPMs
include 'defaults/openstack/rpms';

prefix '/software/packages';
'{openstack-neutron}' ?= dict();
'{openstack-neutron-ml2}' ?= dict();
'{python-neutronclient}' ?= dict();
'{ebtables}' ?= dict();
'{ipset}' ?= dict();
