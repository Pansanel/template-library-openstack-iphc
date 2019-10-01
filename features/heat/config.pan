unique template features/heat/config;

include 'defaults/openstack/schema/schema';

# Load some useful functions
include 'defaults/openstack/functions';

# Include general openstack variables
include 'defaults/openstack/config';

# Fix list of Openstack user that should not be deleted
include 'features/accounts/config';

# Include utils
include 'defaults/openstack/utils';

include 'features/heat/rpms/config';

include 'components/chkconfig/config';
prefix '/software/components/chkconfig/service';
'openstack-heat-api/on' = '';
'openstack-heat-api/startstop' = true;
'openstack-heat-api-cfn/on' = '';
'openstack-heat-api-cfn/startstop' = true;
'openstack-heat-engine/on' = '';
'openstack-heat-engine/startstop' = true;

bind '/software/components/metaconfig/services/{/etc/heat/heat.conf}/contents' = openstack_heat_config;

# Configuration file for Heat
include 'components/metaconfig/config';
prefix '/software/components/metaconfig/services/{/etc/heat/heat.conf}';
'module' = 'tiny';
'daemons/openstack-heat-api' = 'restart';
'daemons/openstack-heat-api-cfn' = 'restart';
'daemons/openstack-heat-engine' = 'restart';

# [DEFAULT] section
'contents/DEFAULT' = openstack_load_config('features/openstack/logging/' + OPENSTACK_LOGGING_TYPE);
'contents/DEFAULT/transport_url' = openstack_dict_to_transport_string(OPENSTACK_RABBITMQ_DICT);
'contents/DEFAULT/log_dir' = '/var/log/heat';
'contents/DEFAULT/region_name_for_services' = OPENSTACK_REGION_NAME;
'contents/DEFAULT/host' = OPENSTACK_HEAT_HOST;
'contents/DEFAULT/heat_metadata_server_url' = openstack_generate_uri(
    OPENSTACK_HEAT_CONTROLLER_PROTOCOL,
    OPENSTACK_HEAT_SERVERS,
    8000
);
'contents/DEFAULT/heat_waitcondition_server_url' = format(
    '%s/%s',
    openstack_generate_uri(
        OPENSTACK_HEAT_CONTROLLER_PROTOCOL,
        OPENSTACK_HEAT_SERVERS,
        8000
    ),
    'v1/waitcondition'
);
'contents/DEFAULT/stack_domain_admin' = OPENSTACK_HEAT_DOMAIN_ADMIN_USERNAME;
'contents/DEFAULT/stack_domain_admin_password' = OPENSTACK_HEAT_DOMAIN_ADMIN_PASSWORD;
'contents/DEFAULT/stack_user_domain_name' = OPENSTACK_HEAT_STACK_DOMAIN;

# [trustee] section
'contents/trustee/auth_type' = 'password';
'contents/trustee/auth_url' = openstack_generate_uri(
    OPENSTACK_KEYSTONE_CONTROLLER_PROTOCOL,
    OPENSTACK_KEYSTONE_SERVERS,
    35357
);
'contents/trustee/username' = OPENSTACK_HEAT_USERNAME;
'contents/trustee/password' = OPENSTACK_HEAT_PASSWORD;
'contents/trustee/user_domain_id' = 'default';

# [clients_keystone] section
'contents/clients_keystone/auth_uri' = format(
    '%s://%s:%d',
    OPENSTACK_KEYSTONE_CONTROLLER_PROTOCOL,
    OPENSTACK_KEYSTONE_CONTROLLER_HOST,
    5000
);

# [database] section
'contents/database/connection' = openstack_dict_to_connection_string(OPENSTACK_HEAT_DB);

# [keystone_authtoken] section
'contents/keystone_authtoken' = openstack_load_config(OPENSTACK_AUTH_CLIENT_CONFIG);
'contents/keystone_authtoken/username' = OPENSTACK_HEAT_USERNAME;
'contents/keystone_authtoken/password' = OPENSTACK_HEAT_PASSWORD;
'contents/keystone_authtoken/memcached_servers' = 'localhost:11211';

include 'components/filecopy/config';
prefix '/software/components/filecopy/services';
'{/root/init-heat.sh}' = dict(
    'perms' , '755',
    'config', format(
        file_contents('features/heat/init-heat.sh'),
        OPENSTACK_INIT_SCRIPT_GENERAL,
        openstack_get_controller_host(OPENSTACK_HEAT_SERVERS),
        openstack_get_controller_host(OPENSTACK_HEAT_SERVERS),
        OPENSTACK_HEAT_USERNAME,
        OPENSTACK_HEAT_PASSWORD,
        OPENSTACK_HEAT_STACK_DOMAIN,
        OPENSTACK_HEAT_DOMAIN_ADMIN_USERNAME,
        OPENSTACK_HEAT_DOMAIN_ADMIN_PASSWORD,
    ),
    'restart' , '/root/init-heat.sh',
);
