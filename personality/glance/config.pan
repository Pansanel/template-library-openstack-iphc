unique template personality/glance/config;

# User running Glance daemons (normally created by RPMs)

variable GLANCE_EMAIL ?= SITE_EMAIL;
variable OPENSTACK_GLANCE_TENANT ?= 'service';
variable OPENSTACK_GLANCE_DB_NAME ?= 'glance';
variable OPENSTACK_GLANCE_USERNAME ?= 'glance';
variable OPENSTACK_GLANCE_PASSWORD ?= error('OPENSTACK_GLANCE_PASSWORD required but not specified');
variable GLANCE_SERVICES ?= list('openstack-glance-api', 'openstack-glance-registry');

# Database related variables
variable GLANCE_MYSQL_ADMINUSER ?= 'root';
variable GLANCE_MYSQL_ADMINPWD ?= error('GLANCE_MYSQL_ADMINPWD required but not specified');
variable OPENSTACK_GLANCE_DB_NAME ?= 'glance';
variable OPENSTACK_GLANCE_DB_USERNAME ?= 'glance';
variable OPENSTACK_GLANCE_DB_PASSWORD ?= error('OPENSTACK_GLANCE_DB_PASSWORD required but not specified');

variable GLANCE_SQL_CONNECTION ?= {
    connection = format(
        'mysql+pymysql://%s:%s@%s/%s',
        OPENSTACK_GLANCE_DB_USERNAME, OPENSTACK_GLANCE_DB_PASSWORD,
        GLANCE_MYSQL_SERVER, OPENSTACK_GLANCE_DB_NAME
    );

    connection;
};

variable GLANCE_USE_RBD ?= false;
variable GLANCE_RBD_STORE_POOL ?= images;
variable GLANCE_RBD_STORE_USER ?= images;

# Memcached related variables
variable MEMCACHED_SERVERS ?= {
    hosts = '';
    foreach(k; v; OPENSTACK_MEMCACHE_HOSTS) {
        if ( hosts != '') {
            hosts = hosts + ',' + v;
        } else {
            hosts = v;
        };
    };

    hosts;
};


#------------------------------------------------------------------------------
# Glance configuration
#------------------------------------------------------------------------------

variable GLANCE_API_CONFIG ?= '/etc/glance/glance-api.conf';

variable GLANCE_API_CONFIG_CONTENTS ?= file_contents('personality/glance/templates/glance-api.templ');

variable GLANCE_API_CONFIG_CONTENTS = {
    contents = SELF;
    contents = replace('TRANSPORT_URL', TRANSPORT_URL, contents);
    contents = replace('SQL_CONNECTION', GLANCE_SQL_CONNECTION, contents);
    contents = replace('KEYSTONE_MGMT_AUTH', KEYSTONE_MGMT_AUTH, contents);
    contents = replace('KEYSTONE_ADMIN_AUTH', KEYSTONE_ADMIN_AUTH, contents);
    contents = replace('MEMCACHED_SERVERS', MEMCACHED_SERVERS, contents);
    contents = replace('GLANCE_TENANT', OPENSTACK_GLANCE_TENANT, contents);
    contents = replace('GLANCE_USERNAME', OPENSTACK_GLANCE_USERNAME, contents);
    contents = replace('GLANCE_PASSWORD', OPENSTACK_GLANCE_PASSWORD, contents);
    contents = replace('REGION_NAME', OPENSTACK_REGION_NAME, contents);
    if (GLANCE_USE_RBD) {
        contents = replace('stores = file,http', 'stores = file,http,rbd', contents);
        contents = replace('default_store = file', 'default_store = rbd', contents);
        contents = replace('RBD_STORE_POOL', GLANCE_RBD_STORE_POOL, contents);
        contents = replace('RBD_STORE_USER', GLANCE_RBD_STORE_USER, contents);
    };

    contents;
};

include 'components/filecopy/config';
"/software/components/filecopy/services" = npush(
    escape(GLANCE_API_CONFIG), dict(
        "config", GLANCE_API_CONFIG_CONTENTS,
        "owner", "root",
        "perms", "0644",
        "restart", "/sbin/service openstack-glance-api restart",
    ),
);

variable GLANCE_REGISTRY_CONFIG ?= '/etc/glance/glance-registry.conf';

variable GLANCE_REGISTRY_CONFIG_CONTENTS ?= file_contents('personality/glance/templates/glance-registry.templ');

variable GLANCE_REGISTRY_CONFIG_CONTENTS = {
    contents = SELF;
    contents = replace('TRANSPORT_URL', TRANSPORT_URL, contents);
    contents = replace('SQL_CONNECTION', GLANCE_SQL_CONNECTION, contents);
    contents = replace('KEYSTONE_MGMT_AUTH', KEYSTONE_MGMT_AUTH, contents);
    contents = replace('KEYSTONE_ADMIN_AUTH', KEYSTONE_ADMIN_AUTH, contents);
    contents = replace('MEMCACHED_SERVERS', MEMCACHED_SERVERS, contents);
    contents = replace('GLANCE_TENANT', OPENSTACK_GLANCE_TENANT, contents);
    contents = replace('GLANCE_USERNAME', OPENSTACK_GLANCE_USERNAME, contents);
    contents = replace('GLANCE_PASSWORD', OPENSTACK_GLANCE_PASSWORD, contents);
    contents = replace('REGION_NAME', OPENSTACK_REGION_NAME, contents);

    contents;
};

"/software/components/filecopy/services" = npush(
    escape(GLANCE_REGISTRY_CONFIG), dict(
        "config", GLANCE_REGISTRY_CONFIG_CONTENTS,
        "owner", "root",
        "perms", "0644",
        "restart", "/sbin/service openstack-glance-registry restart",
    ),
);


#------------------------------------------------------------------------------
# Mariadb configuration
#------------------------------------------------------------------------------

include 'features/mariadb/config';
include 'components/mysql/config';

'/software/components/mysql/servers' = {
    SELF[GLANCE_MYSQL_SERVER]['adminuser'] = GLANCE_MYSQL_ADMINUSER;
    SELF[GLANCE_MYSQL_SERVER]['adminpwd'] = GLANCE_MYSQL_ADMINPWD;
    SELF;
};

'/software/components/mysql/databases' = {
    SELF[OPENSTACK_GLANCE_DB_NAME]['createDb'] = true;
    SELF[OPENSTACK_GLANCE_DB_NAME]['server'] = GLANCE_MYSQL_SERVER;
    SELF[OPENSTACK_GLANCE_DB_NAME]['users'][OPENSTACK_GLANCE_DB_USERNAME] = dict(
        'password', OPENSTACK_GLANCE_DB_PASSWORD,
        'rights', list('ALL PRIVILEGES'),
    );
    SELF;
};


#------------------------------------------------------------------------------
# Endpoint configuration script
#------------------------------------------------------------------------------

variable GLANCE_ENDPOINTS ?= '/root/sbin/create-glance-endpoints.sh';
variable GLANCE_ENDPOINTS_CONTENTS ?= file_contents('personality/glance/templates/create-glance-endpoints.templ');

variable GLANCE_ENDPOINTS_CONTENTS = {
    contents = SELF;
    contents = replace('GLANCE_PASSWORD', OPENSTACK_GLANCE_PASSWORD, contents);
    contents = replace('GLANCE_EMAIL', GLANCE_EMAIL, contents);
    contents = replace('GLANCE_CONTROLLER_HOST', OPENSTACK_GLANCE_CONTROLLER_HOST, contents);
    contents = replace('GLANCE_MGMT_HOST', OPENSTACK_GLANCE_MGMT_HOST, contents);

    contents;
};

"/software/components/filecopy/services" = npush(
    escape(GLANCE_ENDPOINTS), dict(
        "config", GLANCE_ENDPOINTS_CONTENTS,
        "owner", "root",
        "perms", "0700",
    ),
);


#----------------------------------------------------------------------------
# Startup configuration
#----------------------------------------------------------------------------

include 'components/chkconfig/config';

'/software/components/chkconfig/service' = {
    foreach(i; service; GLANCE_SERVICES) {
        SELF[service] = dict(
            'on', '',
            'startstop', true,
        );
    };

    SELF;
};

variable GLANCE_SERVICE_FILE ?= '/etc/service-glance';
variable GLANCE_SERVICE_CONTENTS ?= {
    contents = '';
    foreach(i; service; GLANCE_SERVICES) {
        contents = contents + service + "\n";
    };

    contents;
};

"/software/components/filecopy/services" = npush(
    escape(GLANCE_SERVICE_FILE), dict(
        "config", GLANCE_SERVICE_CONTENTS,
        "owner", "root",
        "perms", "0700",
    ),
);

variable GLANCE_STARTUP_FILE ?= '/etc/init.d/openstack-glance';
variable GLANCE_STARTUP_CONTENTS ?= <<EOF;
#!/bin/sh
#
# OpenStack Glance Services
#
# chkconfig:   - 98 02
# description: Glance is the OpenStack image service
#
### END INIT INFO

SERVICE_LIST=`cat /etc/service-glance`

case "$1" in
    start)
        for s in ${SERVICE_LIST}; do
            echo "*** ${s}:"; 
            /usr/bin/systemctl start ${s}
            echo ""
        done
        ;;
    stop)
        for s in ${SERVICE_LIST}; do
            echo "*** ${s}:";
            /usr/bin/systemctl stop ${s}
            echo ""
        done
        ;;
    restart)
        for s in ${SERVICE_LIST}; do
            echo "*** ${s}:";
            /usr/bin/systemctl stop ${s}
            echo ""
        done
        for s in ${SERVICE_LIST}; do
            echo "*** ${s}:"; 
            /usr/bin/systemctl start ${s}
            echo ""
        done
        ;;
    status)
        for s in ${SERVICE_LIST}; do
            echo "*** ${s}:";
            /usr/bin/systemctl status ${s}
            echo ""
        done
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart"
        exit 1;; 
esac
exit 0
EOF

"/software/components/filecopy/services" = npush(
    escape(GLANCE_STARTUP_FILE), dict(
        "config", GLANCE_STARTUP_CONTENTS,
        "owner", "root:root",
        "perms", "0755",
    ),
);
