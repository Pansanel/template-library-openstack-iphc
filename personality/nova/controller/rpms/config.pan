template personality/nova/controller/rpms/config;

# Include some useful RPMs
include 'defaults/openstack/rpms';

prefix '/software/packages';

'{openstack-nova-api}' ?= nlist();
'{openstack-nova-conductor}' ?= nlist();
'{openstack-nova-console}' ?= nlist();
'{openstack-nova-novncproxy}' ?= nlist();
'{openstack-nova-placement-api}' ?= nlist();
'{openstack-nova-scheduler}' ?= nlist();
'{python-novaclient}' ?= nlist();
