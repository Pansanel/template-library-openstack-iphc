template machine-types/openstack/compute_node;

# Include base configuration of a Cloud node
include { 'machine-types/openstack/base' };

# Nova compute configuration
include { 'personality/nova/compute/service' };

# Neutron client configuration
include { 'personality/neutron/compute/service' };
