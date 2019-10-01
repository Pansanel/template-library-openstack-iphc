unique template personality/cinder/config;

variable CINDER_SERVER_SERVICES ?= list();
variable CINDER_VOLUME_SERVICES ?= list();
variable CINDER_SERVICES = merge(CINDER_SERVER_SERVICES, CINDER_VOLUME_SERVICES);

variable OPENSTACK_CINDER_TENANT ?= 'service';
variable OPENSTACK_CINDER_USERNAME ?= 'cinder';
variable OPENSTACK_CINDER_PASSWORD ?=  error('OPENSTACK_CINDER_PASSWORD required but not specified');

variable GLANCE_URL ?= 'http://' + OPENSTACK_GLANCE_MGMT_HOST + ':9292';
variable CINDER_SQL_CONNECTION ?= format(
    'mysql+pymysql://%s:%s@%s/%s',
    OPENSTACK_CINDER_DB_USERNAME, OPENSTACK_CINDER_DB_PASSWORD,
    CINDER_MYSQL_SERVER, OPENSTACK_CINDER_DB_NAME
);

# Memcached related variables
variable MEMCACHED_SERVERS ?= {
    hosts = '';
    foreach(k; v; OPENSTACK_MEMCACHE_HOSTS) {
        if ( hosts != '') {
            hosts = hosts + ',' + k;
        } else {
            hosts = k;
        };
    };

    hosts;
};

variable GLANCE_API_SERVERS = OPENSTACK_GLANCE_MGMT_HOST + ':9292';


#------------------------------------------------------------------------------
# Cinder configuration
#------------------------------------------------------------------------------

variable CINDER_CONFIG ?= '/etc/cinder/cinder.conf';

variable CINDER_CONFIG_CONTENTS ?= file_contents('personality/cinder/templates/cinder.templ');

variable CINDER_CONFIG_CONTENTS = {
    contents = SELF;
    contents = replace('HOST_IP', DB_IP[escape(FULL_HOSTNAME)], contents);
    contents = replace('GLANCE_API_SERVERS', GLANCE_API_SERVERS, contents);
    contents = replace('TRANSPORT_URL', TRANSPORT_URL, contents);
    contents = replace('GLANCE_URL', GLANCE_URL, contents);
    contents = replace('SQL_CONNECTION', CINDER_SQL_CONNECTION, contents);
    contents = replace('KEYSTONE_MGMT_AUTH', KEYSTONE_MGMT_AUTH, contents);
    contents = replace('KEYSTONE_ADMIN_AUTH', KEYSTONE_ADMIN_AUTH, contents);
    contents = replace('REGION_NAME', OPENSTACK_REGION_NAME, contents);
    contents = replace('CINDER_TENANT', OPENSTACK_CINDER_TENANT, contents);
    contents = replace('CINDER_USERNAME', OPENSTACK_CINDER_USERNAME, contents);
    contents = replace('CINDER_PASSWORD', OPENSTACK_CINDER_PASSWORD, contents);
    contents = replace('MEMCACHED_SERVERS', MEMCACHED_SERVERS, contents);

    contents;
};

include 'components/filecopy/config';
"/software/components/filecopy/services" = npush(
    escape(CINDER_CONFIG), dict(
        "config", CINDER_CONFIG_CONTENTS,
        "owner", "root",
        "perms", "0644",
        "restart", "/sbin/service openstack-cinder restart",
    ),
);


#----------------------------------------------------------------------------
# Startup configuration
#----------------------------------------------------------------------------

include 'components/chkconfig/config';

'/software/components/chkconfig/service' = {
    foreach(i; service; CINDER_SERVICES) {
        SELF[service] = dict(
            'on', '',
            'startstop', true,
        );
    };

    SELF;
};

variable CINDER_SERVICE_FILE ?= '/etc/service-cinder';
variable CINDER_SERVICE_CONTENTS ?= {
    contents = '';
    foreach(i; service; CINDER_SERVICES) {
        contents = contents + service + "\n";
    };
    contents;
};

"/software/components/filecopy/services" = npush(
    escape(CINDER_SERVICE_FILE), dict(
        "config", CINDER_SERVICE_CONTENTS,
        "owner", "root",
        "perms", "0700",
    ),
);

variable CINDER_STARTUP_FILE ?= '/etc/init.d/openstack-cinder';
variable CINDER_STARTUP_CONTENTS ?= <<EOF;
#!/bin/sh
#
# OpenStack Cinder Services
#
# chkconfig:   - 98 02
# description: Cinder is the OpenStack block storage service
#
### END INIT INFO

SERVICE_LIST=`cat /etc/service-cinder`

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
    escape(CINDER_STARTUP_FILE), dict(
        "config", CINDER_STARTUP_CONTENTS,
        "owner", "root:root",
        "perms", "0755",
    ),
);
