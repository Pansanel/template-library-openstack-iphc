
unique template personality/keystone/service;

variable KEYSTONE_MYSQL_SERVER ?= OPENSTACK_DB_HOST;

# Add RPMs for Keystone
include { 'personality/keystone/rpms/config' };

# Add Keystone server configuration
include { 'personality/keystone/config' };

# Configure MySQL server
include { 'features/mariadb/config' };

# Configure httpd
include 'features/httpd/config';

# Configure memcache
include 'features/memcache/config';

# Add accepted CAs certificates
include { if (OPENSTACK_CONFIGURE_VOS) 'security/cas' };

# Update the certificate revocation lists.
include { if (OPENSTACK_CONFIGURE_VOS) 'features/fetch-crl/config' };
#include 'defaults/grid/config';
# Configure VOs
include { if (OPENSTACK_CONFIGURE_VOS) 'vo/config' };
