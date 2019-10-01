template machine-types/openstack/network_node;

# Include base configuration of a Cloud node
include { 'machine-types/openstack/base' };

# Neutron controller configuration
include { 'personality/neutron/network/service' };

