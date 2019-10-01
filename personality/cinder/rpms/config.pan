template personality/cinder/rpms/config;

prefix '/software/packages';

'{openstack-cinder}' ?= dict();
'{openstack-utils}' ?= dict();
'{openstack-selinux}' ?= dict();
'{python-keystone}' ?= dict();
'{device-mapper-persistent-data}' ?= dict();
