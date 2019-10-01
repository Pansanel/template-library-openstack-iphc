template personality/nova/config; 

variable MY_IP ?= DB_IP[escape(FULL_HOSTNAME)];
variable VNCSERVER_LISTEN ?= "0.0.0.0";
variable VNCSERVER_PROXYCLIENT_ADDRESS ?= MY_IP;
variable NOVNCPROXY_BASE_URL ?= 'http://'+OPENSTACK_NOVA_CONTROLLER_HOST+':6080/vnc_auto.html';
variable XVPVNCPROXY_BASE_URL ?= 'http://'+OPENSTACK_NOVA_CONTROLLER_HOST+':6081/console';
variable OPENSTACK_NOVA_TENANT ?= 'service';
variable OPENSTACK_NOVA_USERNAME ?= 'nova';
variable OPENSTACK_NOVA_PASSWORD ?= error('OPENSTACK_NOVA_PASSWORD required but not specified');
variable OPENSTACK_PLACEMENT_USERNAME ?= 'placement';
variable OPENSTACK_PLACEMENT_PASSWORD ?= error('OPENSTACK_PLACEMENT_PASSWORD required but not specified');

variable GLANCE_URL ?= 'http://' + OPENSTACK_GLANCE_MGMT_HOST + ':9292';

# Neutron related variables
variable NEUTRON_URL ?= 'http://' + OPENSTACK_NEUTRON_MGMT_HOST + ':9696';
variable OPENSTACK_NEUTRON_TENANT ?= 'service';
variable OPENSTACK_NEUTRON_USERNAME ?= 'neutron';
variable OPENSTACK_NEUTRON_PASSWORD ?= error('OPENSTACK_NEUTRON_PASSWORD required but not specified');

# Nova - Neutron related variables
variable DEFAULT_FLOATING_IP_POOL ?= 'ext-net';

# Database related variables
variable NOVA_MYSQL_SERVER ?= OPENSTACK_DB_HOST;
variable OPENSTACK_NOVA_DB_NAME ?= 'nova';
variable OPENSTACK_NOVA_API_DB_NAME ?= 'nova_api';
variable OPENSTACK_NOVA_CELL_DB_NAME ?= 'nova_cell0';
variable OPENSTACK_NOVA_DB_USERNAME ?= 'nova';
variable OPENSTACK_NOVA_DB_PASSWORD ?= error('NOVA_DB_PASSWORD required but not specified');
variable OPENSTACK_PLACEMENT_DB_NAME ?= 'placement';
variable OPENSTACK_PLACEMENT_DB_USERNAME ?= 'placement';
variable OPENSTACK_PLACEMENT_DB_PASSWORD ?= error('PLACEMENT_DB_PASSWORD required but not specified');

variable NOVA_SQL_CONNECTION ?= 'mysql+pymysql://'+OPENSTACK_NOVA_DB_USERNAME+':'+OPENSTACK_NOVA_DB_PASSWORD+'@'+NOVA_MYSQL_SERVER+'/'+OPENSTACK_NOVA_DB_NAME;
variable NOVA_API_SQL_CONNECTION ?= 'mysql+pymysql://'+OPENSTACK_NOVA_DB_USERNAME+':'+OPENSTACK_NOVA_DB_PASSWORD+'@'+NOVA_MYSQL_SERVER+'/'+OPENSTACK_NOVA_API_DB_NAME;
variable NOVA_CELL_SQL_CONNECTION ?= 'mysql+pymysql://'+OPENSTACK_NOVA_DB_USERNAME+':'+OPENSTACK_NOVA_DB_PASSWORD+'@'+NOVA_MYSQL_SERVER+'/'+OPENSTACK_NOVA_CELL_DB_NAME;
variable PLACEMENT_SQL_CONNECTION ?= 'mysql+pymysql://'+OPENSTACK_PLACEMENT_DB_USERNAME+':'+OPENSTACK_PLACEMENT_DB_PASSWORD+'@'+NOVA_MYSQL_SERVER+'/'+OPENSTACK_PLACEMENT_DB_NAME;

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

variable ENABLED_APIS ?= 'osapi_compute,metadata';


#------------------------------------------------------------------------------
# Nova Configuration
#------------------------------------------------------------------------------

variable NOVA_CONFIG ?= '/etc/nova/nova.conf';

variable NOVA_CONFIG_CONTENTS ?= file_contents('personality/nova/templates/nova.templ');

variable NOVA_CONFIG_CONTENTS = {
    contents = SELF;
    contents = replace('MY_IP', MY_IP, contents);
    contents = replace('REGION_NAME', OPENSTACK_REGION_NAME, contents);
    contents = replace('VNCSERVER_LISTEN', VNCSERVER_LISTEN, contents);
    contents = replace('VNCSERVER_PROXYCLIENT_ADDRESS', VNCSERVER_PROXYCLIENT_ADDRESS, contents);
    contents = replace('XVPVNCPROXY_BASE_URL', XVPVNCPROXY_BASE_URL, contents);
    contents = replace('DEFAULT_FLOATING_IP_POOL', DEFAULT_FLOATING_IP_POOL, contents);
    contents = replace('MEMCACHED_SERVERS', MEMCACHED_SERVERS, contents);

    if (VNCSERVER_LISTEN == "0.0.0.0") {
        contents = replace('VNC_ENABLED','true', contents);
    } else {
        contents = replace('VNC_ENABLED','false', contents);
    };

    if (VNCSERVER_LISTEN == "0.0.0.0") {
        contents = replace('#novncproxy_base_url=http://127.0.0.1:6080/vnc_auto.html', 'novncproxy_base_url=' + NOVNCPROXY_BASE_URL, contents);
    };

    contents = replace('GLANCE_URL', GLANCE_URL, contents);
    contents = replace('TRANSPORT_URL', TRANSPORT_URL, contents);
    contents = replace('NOVA_SQL_CONNECTION', NOVA_SQL_CONNECTION, contents);
    contents = replace('NOVA_API_SQL_CONNECTION', NOVA_API_SQL_CONNECTION, contents);
    contents = replace('PLACEMENT_SQL_CONNECTION', PLACEMENT_SQL_CONNECTION, contents);
    contents = replace('KEYSTONE_MGMT_AUTH', KEYSTONE_MGMT_AUTH, contents);
    contents = replace('KEYSTONE_ADMIN_AUTH', KEYSTONE_ADMIN_AUTH, contents);
    contents = replace('NOVA_TENANT', OPENSTACK_NOVA_TENANT, contents);
    contents = replace('NOVA_USERNAME', OPENSTACK_NOVA_USERNAME, contents);
    contents = replace('NOVA_PASSWORD', OPENSTACK_NOVA_PASSWORD, contents);
    contents = replace('PLACEMENT_USERNAME', OPENSTACK_PLACEMENT_USERNAME, contents);
    contents = replace('PLACEMENT_PASSWORD', OPENSTACK_PLACEMENT_PASSWORD, contents);

    contents = replace('METADATA_PROXY_ENABLED', 'true', contents);

    contents = replace('#metadata_proxy_shared_secret=METADATA_PROXY_SHARED_SECRET', 'metadata_proxy_shared_secret='+METADATA_PROXY_SHARED_SECRET, contents);

    contents = replace('NEUTRON_URL', NEUTRON_URL, contents);
    contents = replace('REGION_NAME', OPENSTACK_REGION_NAME, contents);
    contents = replace('NEUTRON_USERNAME', OPENSTACK_NEUTRON_USERNAME, contents);
    contents = replace('NEUTRON_PASSWORD', OPENSTACK_NEUTRON_PASSWORD, contents);
    contents = replace('NEUTRON_TENANT', OPENSTACK_NEUTRON_TENANT, contents);

    contents;
};

"/software/components/filecopy/services" = npush(
    escape(NOVA_CONFIG), dict(
        "config", NOVA_CONFIG_CONTENTS,
        "owner","root",
        "perms","0644",
        "restart", "/sbin/service openstack-nova restart",
    ),
);


#------------------------------------------------------------------------------
# Nova API configuration
#------------------------------------------------------------------------------

variable NOVA_API ?= '/etc/nova/api-paste.ini';

variable NOVA_API_CONTENTS ?= file_contents('personality/nova/templates/api-paste.templ');

variable NOVA_API_CONTENTS = replace('AUTH_URI', KEYSTONE_CONTROLLER_AUTH, NOVA_API_CONTENTS);

"/software/components/filecopy/services" = npush(
    escape(NOVA_API), dict(
        "config", NOVA_API_CONTENTS,
        "owner", "root",
        "perms", "0644",
        "restart", "/sbin/service openstack-nova restart",
    ),
);


#----------------------------------------------------------------------------
# Startup configuration
#----------------------------------------------------------------------------

include 'components/chkconfig/config';

'/software/components/chkconfig/service'= {
    foreach(i; service; NOVA_SERVICES) {
        SELF[service] = dict(
            'on','',
            'startstop',true,
        );
    };

    SELF;
};

variable NOVA_SERVICE_FILE ?= '/etc/service-nova';
variable NOVA_SERVICE_CONTENTS ?= {
    contents = '';
    foreach(i; service; NOVA_SERVICES) {
        contents = contents + service + "\n";
    };
    contents;
};

"/software/components/filecopy/services" = npush(
    escape(NOVA_SERVICE_FILE), dict(
        "config", NOVA_SERVICE_CONTENTS,
        "owner", "root",
        "perms", "0700",
    ),
);

variable NOVA_STARTUP_FILE ?= '/etc/init.d/openstack-nova';
variable NOVA_STARTUP_CONTENTS ?= <<EOF;
#!/bin/sh
#
# OpenStack Nova Services
#
# chkconfig:   - 98 02
# description: Nova is the OpenStack cloud computing fabric controller
#
### END INIT INFO

SERVICE_LIST=`cat /etc/service-nova`

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
    escape(NOVA_STARTUP_FILE), dict(
        "config", NOVA_STARTUP_CONTENTS,
        "owner", "root:root",
        "perms", "0755",
    ),
);
