structure template features/keystone/client/config;

'www_authenticate_uri' = openstack_generate_uri(
    OPENSTACK_KEYSTONE_CONTROLLER_PROTOCOL,
    OPENSTACK_KEYSTONE_SERVERS,
    OPENSTACK_KEYSTONE_PORT
) + '/v3';
'auth_url' = openstack_generate_uri(
    OPENSTACK_KEYSTONE_CONTROLLER_PROTOCOL,
    OPENSTACK_KEYSTONE_SERVERS,
    OPENSTACK_KEYSTONE_ADMIN_PORT
);
'project_domain_name' = 'default';
'user_domain_name' = 'default';
'project_name' = 'service';
'auth_type' = 'password';
