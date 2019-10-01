unique template features/magnum/config;

include 'defaults/openstack/schema/schema';

# Load some useful functions
include 'defaults/openstack/functions';

# Include general openstack variables
include 'defaults/openstack/config';

# Fix list of Openstack user that should not be deleted
include 'features/accounts/config';

# Include utils
include 'defaults/openstack/utils';

# Add RPMs for Magnum 
include 'features/magnum/rpms/config';

include 'components/chkconfig/config';
prefix '/software/components/chkconfig/service';
'openstack-magnum-api/on' = '';
'openstack-magnum-api/startstop' = true;
'openstack-magnum-conductor/on' = '';
'openstack-magnum-conductor/startstop' = true;

bind '/software/components/metaconfig/services/{/etc/magnum/magnum.conf}/contents' = openstack_magnum_config;

# Configuration file for Magnum
include 'components/metaconfig/config';
prefix '/software/components/metaconfig/services/{/etc/magnum/magnum.conf}';
'module' = 'tiny';
'daemons/openstack-magnum-api' = 'restart';
'daemons/openstack-magnum-conductor' = 'restart';

# [DEFAULT] section
'contents/DEFAULT' = openstack_load_config('features/openstack/logging/' + OPENSTACK_LOGGING_TYPE);
'contents/DEFAULT/transport_url' = openstack_dict_to_transport_string(OPENSTACK_RABBITMQ_DICT);
'contents/DEFAULT/log_dir' = '/var/log/magnum';
'contents/DEFAULT/host' = OPENSTACK_MAGNUM_HOST;

# [api] section
'contents/api/host' = OPENSTACK_MAGNUM_API_HOST;

# [certificates] section (barbican is recommended for production environments)
'contents/certificates/cert_manager_type' = 'barbican';

# [cinder] section
'contents/cinder/default_docker_volume_type' = OPENSTACK_MAGNUM_DEFAULT_VOLUME_TYPE;

# [cinder_client] section
'contents/cinder_client/region_name' = OPENSTACK_REGION_NAME;

# [database] section
'contents/database/connection' = openstack_dict_to_connection_string(OPENSTACK_MAGNUM_DB);

# [keystone_auth] section
'contents/keystone_auth/auth_url' = openstack_generate_uri(
    OPENSTACK_KEYSTONE_CONTROLLER_PROTOCOL,
    OPENSTACK_KEYSTONE_SERVERS,
    OPENSTACK_KEYSTONE_ADMIN_PORT
);
'contents/keystone_auth/auth_type' = 'password';
'contents/keystone_auth/username' = OPENSTACK_MAGNUM_USERNAME;
'contents/keystone_auth/password' = OPENSTACK_MAGNUM_PASSWORD;
'contents/keystone_auth/project_name' = 'service';
'contents/keystone_auth/project_domain_id' = 'default';
'contents/keystone_auth/user_domain_id' = 'default';

# [keystone_authtoken] section
'contents/keystone_authtoken' = openstack_load_config(OPENSTACK_AUTH_CLIENT_CONFIG);
'contents/keystone_authtoken/memcached_servers' = 'localhost:11211';
'contents/keystone_authtoken/username' = OPENSTACK_MAGNUM_USERNAME;
'contents/keystone_authtoken/password' = OPENSTACK_MAGNUM_PASSWORD;
'contents/keystone_authtoken/admin_user' = OPENSTACK_MAGNUM_USERNAME;
'contents/keystone_authtoken/admin_password' = OPENSTACK_MAGNUM_PASSWORD;
'contents/keystone_authtoken/admin_tenant_name' = 'service';
'contents/keystone_authtoken/auth_version' = 'v3';

# [oslo_concurrency] section
'contents/oslo_concurrency/lock_path' = '/var/lib/magnum/tmp';

# [oslo_messaging_notifications]
'contents/oslo_messaging_notifications/driver' = 'messaging';

# [trust] section
'contents/trust/trustee_domain_name' = 'magnum';
'contents/trust/trustee_domain_admin_name' = OPENSTACK_MAGNUM_DOMAIN_ADMIN_USERNAME;
'contents/trust/trustee_domain_admin_password' = OPENSTACK_MAGNUM_DOMAIN_ADMIN_PASSWORD;
'contents/trust/trustee_keysone_interface' = 'public';


include 'components/filecopy/config';
prefix '/software/components/filecopy/services';
'{/root/init-magnum.sh}' = dict(
    'perms' , '755',
    'config', format(
        file_contents('features/magnum/init-magnum.sh'),
        OPENSTACK_INIT_SCRIPT_GENERAL,
        OPENSTACK_KEYSTONE_MGMT_HOST,
        OPENSTACK_MAGNUM_USERNAME,
        OPENSTACK_MAGNUM_PASSWORD,
        OPENSTACK_MAGNUM_DOMAIN_ADMIN_USERNAME,
        OPENSTACK_MAGNUM_DOMAIN_ADMIN_PASSWORD,
    ),
    'restart', '/root/init-magnum.sh',
);

