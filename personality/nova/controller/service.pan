
unique template personality/nova/controller/service;

variable NOVA_MYSQL_SERVER ?= OPENSTACK_DB_HOST;

# Add RPMs for Nova
include { 'personality/nova/controller/rpms/config' };

variable NODE_USE_RESOURCE_BDII = true;
# Configure BDII
include { 'personality/bdii/service' };

include 'features/gip/base';
include 'features/gip/openstack';

include { 'features/bdii/rpms' };
# Add Nova controller configuration
include { 'personality/nova/controller/config' };
