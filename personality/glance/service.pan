
unique template personality/glance/service;

variable GLANCE_MYSQL_SERVER ?= OPENSTACK_DB_HOST;

# Add RPMs for Glance
include { 'personality/glance/rpms/config' };

# Add Cinder server configuration
include { 'personality/glance/config' };
