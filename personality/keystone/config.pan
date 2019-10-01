unique template personality/keystone/config;

# User running Keystone daemons (normally created by RPMs)
variable KEYSTONE_USER ?= 'keystone';
variable KEYSTONE_GROUP ?= 'keystone';

# Generate the admin token with `openssl rand -hex 10`
variable OPENSTACK_ADMIN_TOKEN ?= error('ADMIN_TOKEN required but not specified');

# Base endpoints URLs for Keystone
variable PUBLIC_ENDPOINT ?= OPENSTACK_KEYSTONE_CONTROLLER_PROTOCOL + '://' + OPENSTACK_KEYSTONE_CONTROLLER_HOST + ':%(public_port)s/';
variable ADMIN_ENDPOINT ?= OPENSTACK_KEYSTONE_MGMT_PROTOCOL + '://' + OPENSTACK_KEYSTONE_MGMT_HOST + ':%(admin_port)s/';


# Database related variables
variable KEYSTONE_MYSQL_ADMINUSER ?= 'root';
variable KEYSTONE_MYSQL_ADMINPWD ?= error('KEYSTONE_MYSQL_ADMINPWD required but not specified');
variable OPENSTACK_KEYSTONE_DB_NAME ?= 'keystone';
variable OPENSTACK_KEYSTONE_DB_USERNAME ?= 'keystone';
variable OPENSTACK_KEYSTONE_DB_PASSWORD ?= error('KEYSTONE_DB_PASSWORD required but not specified');
variable KEYSTONE_SQL_CONNECTION ?= 'mysql+pymysql://'+OPENSTACK_KEYSTONE_DB_USERNAME+':'+OPENSTACK_KEYSTONE_DB_PASSWORD+'@'+KEYSTONE_MYSQL_SERVER+'/'+OPENSTACK_KEYSTONE_DB_NAME;

# Memcached related variables
variable MEMCACHED_SERVERS ?= {
    hosts = '';
    foreach(k;v;OPENSTACK_MEMCACHE_HOSTS) {
        if ( hosts != '') {
            hosts = hosts + ',' + k;
        } else {
            hosts = k;
        };
    };

    hosts;
};


#------------------------------------------------------------------------------
# OpenID configuration
#------------------------------------------------------------------------------

variable AUTH_METHODS ?= if (OPENSTACK_OPENID) {
  'external,password,token,oauth1,openid';
} else {
  'external,password,token,oauth1';
};

variable OIDC_CONTENTS ?= {
  contents = '';
  if (OPENSTACK_OPENID) {
    contents = contents + "[openid]\n";
    contents = contents + "# this is the attribute in the Keystone environment that will define the\n";
    contents = contents + "# identity provider\n";
    contents = contents + "remote_id_attribute = HTTP_OIDC_ISS\n";
    contents = contents + "\n";
    contents = contents + "\n";
  };
  contents;
};

variable TRUSTED_DASHBOARD ?= 'trusted_dashboard = ' + OPENSTACK_DASHBOARD_PROTOCOL + '://' + OPENSTACK_DASHBOARD_HOST + '/dashboard/auth/websso/';

#------------------------------------------------------------------------------
# Keystone configuration
#------------------------------------------------------------------------------

variable KEYSTONE_CONFIG ?= '/etc/keystone/keystone.conf';

variable KEYSTONE_CONFIG_CONTENTS ?= file_contents('personality/keystone/templates/keystone.templ');

variable KEYSTONE_CONFIG_CONTENTS=replace('ADMIN_TOKEN',OPENSTACK_ADMIN_TOKEN,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('PUBLIC_ENDPOINT',PUBLIC_ENDPOINT,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('ADMIN_ENDPOINT',ADMIN_ENDPOINT,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('SQL_CONNECTION',KEYSTONE_SQL_CONNECTION,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('TRANSPORT_URL',TRANSPORT_URL,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('MEMCACHED_SERVERS',MEMCACHED_SERVERS,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('MEMCACHED_SERVERS',MEMCACHED_SERVERS,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('AUTH_METHODS',AUTH_METHODS,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS=replace('OIDC_CONTENTS',OIDC_CONTENTS,KEYSTONE_CONFIG_CONTENTS);
variable KEYSTONE_CONFIG_CONTENTS={
  if (OPENSTACK_OPENID) {
    replace('#trusted_dashboard =',TRUSTED_DASHBOARD, KEYSTONE_CONFIG_CONTENTS);
  } else {
    KEYSTONE_CONFIG_CONTENTS;
  };
};

"/software/components/filecopy/services" = npush(
    escape(KEYSTONE_CONFIG), nlist(
        "config",KEYSTONE_CONFIG_CONTENTS,
        "owner","root",
        "perms","0644",
        "restart", "/sbin/service httpd restart",
    ),
);


#------------------------------------------------------------------------------
# Keystone Paste configuration
#------------------------------------------------------------------------------

variable KEYSTONE_PASTE ?= '/etc/keystone/keystone-paste.ini';

variable KEYSTONE_PASTE_CONTENTS ?= file_contents('personality/keystone/templates/keystone-paste.templ');

"/software/components/filecopy/services" = npush(
    escape(KEYSTONE_PASTE), nlist(
        "config",KEYSTONE_PASTE_CONTENTS,
        "owner","root",
        "perms","0644",
        "restart", "/sbin/service httpd restart",
    ),
);


#------------------------------------------------------------------------------
# MySQL configuration
#------------------------------------------------------------------------------

include { 'components/mysql/config' };

'/software/components/mysql/servers/' = {
    SELF[KEYSTONE_MYSQL_SERVER]['adminuser'] = KEYSTONE_MYSQL_ADMINUSER;
    SELF[KEYSTONE_MYSQL_SERVER]['adminpwd'] = KEYSTONE_MYSQL_ADMINPWD;
    SELF;
};

'/software/components/mysql/databases/' = {
    SELF[OPENSTACK_KEYSTONE_DB_NAME]['createDb'] = true;
    SELF[OPENSTACK_KEYSTONE_DB_NAME]['server'] = KEYSTONE_MYSQL_SERVER;
    SELF[OPENSTACK_KEYSTONE_DB_NAME]['users'][OPENSTACK_KEYSTONE_DB_USERNAME] = nlist(
        'password', OPENSTACK_KEYSTONE_DB_PASSWORD,
        'rights', list('ALL PRIVILEGES'),
    );
    SELF;
};

