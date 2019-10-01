
unique template personality/cinder/service;

# DB Related variables
variable CINDER_MYSQL_SERVER ?= OPENSTACK_DB_HOST;
variable OPENSTACK_CINDER_DB_NAME ?= 'cinder';
variable OPENSTACK_CINDER_DB_USERNAME ?= 'cinder';
variable OPENSTACK_CINDER_DB_PASSWORD ?= error('CINDER_DB_PASSWORD required but not specified');

variable CINDER_SERVER_ENABLED ?= true;

variable CINDER_VOLUME_ENABLED ?= true;

# Add RPMs for Cinder
include { 'personality/cinder/rpms/config' };

include { if (CINDER_SERVER_ENABLED) 'personality/cinder/server' };

include { if (CINDER_VOLUME_ENABLED) 'personality/cinder/volume' };

# Add Cinder server configuration
include { 'personality/cinder/config' };
