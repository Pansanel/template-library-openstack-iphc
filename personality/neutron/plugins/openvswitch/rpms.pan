unique template personality/neutron/plugins/openvswitch/rpms;

prefix '/software/packages';

'{openstack-neutron-openvswitch}' ?= dict();
'{ipset}' ?= dict();
# Fix an openvswitch dependency
'{libibverbs}' ?= dict();
