# openstack-rocky

## Installation
* Install repository under cfg/openstack/rocky
* Add openstack/rocky into cluster.build.properties

## Usage
* Create a template site/openstack/config

Look @ defaults/openstack/config.pan to have a list of all needed variables

## Some comment
* Default username and password are the same than those you have on RDO documentation
* We try to avoid filecopy config and prefer metaconfig usage. .tt file are provide with filecopy as far as it is not
available officialy

## Supported services
* Keystone: Apache configuration of keystone. sql or ldap backend is supported for user.
* Glance: Filesystem or ceph based glance are supported
* Nova
* Neutron: "self-service" or "provider" configuration is supported with either linuxbridge or OpenVSwitch networking. Distributed Virtual Routing is also supported with OpenVSwitch
* Cinder: "lvm" and "ceph" based backend are supported
* Barbican
* Heat
* Magnum


## TODO
* metaconfig is now PARTIALLY typed
* Database is not populate
  * an init script is created and run automatically for each component to add appropriate objects within OpenStack (user, domain, role, project, service, endpoints) and to run the database initialisation. This currently does not deal with updating the database when upgrading
