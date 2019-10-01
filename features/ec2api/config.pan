unique template features/ec2api/config;

# Include general openstack variables
include 'defaults/openstack/config';

# Fix list of Openstack user that should not be deleted
#include 'features/accounts/config';

# Add RPMs for Heat
#include 'features/ec2/rpms/config';

variable EC2API_EMAIL ?= SITE_EMAIL;
variable OPENSTACK_EC2API_PROJECT ?= 'service';
variable OPENSTACK_EC2API_DB_NAME ?= 'ec2api';
variable OPENSTACK_EC2API_USERNAME ?= 'ec2api';
variable OPENSTACK_EC2API_PASSWORD ?= error('OPENSTACK_EC2API_PASSWORD required but not specified');
variable OPENSTACK_EC2API_DOMAIN_NAME ?= 'Default';
variable OPENSTACK_EC2API_PORT ?= '8773';
variable EC2API_SERVICES ?= list('ec2-api', 'ec2-api-metadata');
variable EC2API_CONTROLLER_HOST ?= OPENSTACK_CONTROLLER_HOST;
variable EC2API_MGMT_CONTROLLER_HOST ?= OPENSTACK_MGMT_CONTROLLER_HOST;
variable EC2API_LOG_DIR ?= '/var/log/ec2api';
variable EC2API_AUTH_CACHE_DIR ?= '/var/cache/ec2api';

# Database related variables
variable EC2API_MYSQL_SERVER ?= OPENSTACK_DB_HOST;
variable EC2API_MYSQL_ADMINUSER ?= 'root';
variable EC2API_MYSQL_ADMINPWD ?= error('EC2API_MYSQL_ADMINPWD required but not specified');
variable OPENSTACK_EC2API_DB_NAME ?= 'ec2api';
variable OPENSTACK_EC2API_DB_USERNAME ?= 'ec2api';
variable OPENSTACK_EC2API_DB_PASSWORD ?= error('OPENSTACK_EC2API_DB_PASSWORD required but not specified');

variable EC2API_SQL_CONNECTION ?= 'mysql+pymysql://'+OPENSTACK_EC2API_DB_USERNAME+':'+OPENSTACK_EC2API_DB_PASSWORD+'@'+EC2API_MYSQL_SERVER+'/'+OPENSTACK_EC2API_DB_NAME;


#------------------------------------------------------------------------------
# ec2-api configuration
#------------------------------------------------------------------------------

variable EC2API_CONFIG ?= '/etc/ec2api/ec2api.conf';
variable EC2API_SIGNING_DIR ?= '/var/cache/ec2api';
variable EC2API_APIPASTE_CONFIG ?= '/etc/ec2api/api-paste.ini';
variable EC2API_AUTH_CACHE_DIR ?= EC2API_SIGNING_DIR;

variable EC2API_CONFIG_CONTENTS ?= file_contents('features/ec2api/templates/ec2api.templ');

#variable EC2API_CONFIG_CONTENTS=replace('LISTEN_IP',EC2API_LISTEN_IP,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('MY_IP',MY_IP,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('EC2API_PORT',OPENSTACK_EC2API_PORT,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('SQL_CONNECTION',EC2API_SQL_CONNECTION,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('RABBIT_HOST',OPENSTACK_RABBITMQ_HOST,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('RABBIT_USER',OPENSTACK_RABBITMQ_USERNAME,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('RABBIT_PASSWORD',OPENSTACK_RABBITMQ_PASSWORD,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('REGION_NAME',OPENSTACK_REGION_NAME,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('KEYSTONE_MGMT_AUTH',KEYSTONE_MGMT_AUTH,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('MEMCACHED_SERVERS',MEMCACHED_SERVERS,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('KEYSTONE_ADMIN_AUTH',KEYSTONE_ADMIN_AUTH,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('EC2API_PROJECT',OPENSTACK_EC2API_PROJECT,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('EC2API_USERNAME',OPENSTACK_EC2API_USERNAME,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('EC2API_PASSWORD',OPENSTACK_EC2API_PASSWORD,EC2API_CONFIG_CONTENTS);
variable EC2API_CONFIG_CONTENTS=replace('EC2API_DOMAIN_NAME',OPENSTACK_EC2API_DOMAIN_NAME,EC2API_CONFIG_CONTENTS);

"/software/components/filecopy/services" = npush(
    escape(EC2API_CONFIG), nlist(
        "config",EC2API_CONFIG_CONTENTS,
        "owner","root",
        "perms","0644",
        "restart", "/sbin/service openstack-ec2api restart",
    ),
);


#------------------------------------------------------------------------------
# Mariadb configuration
#------------------------------------------------------------------------------

include 'features/mariadb/config';

'/software/components/mysql/servers/' = {
    SELF[EC2API_MYSQL_SERVER]['adminuser'] = EC2API_MYSQL_ADMINUSER;
    SELF[EC2API_MYSQL_SERVER]['adminpwd'] = EC2API_MYSQL_ADMINPWD;
    SELF;
};

'/software/components/mysql/databases/' = {
    SELF[OPENSTACK_EC2API_DB_NAME]['createDb'] = true;
    SELF[OPENSTACK_EC2API_DB_NAME]['server'] = EC2API_MYSQL_SERVER;
    SELF[OPENSTACK_EC2API_DB_NAME]['users'][OPENSTACK_EC2API_DB_USERNAME] = nlist(
        'password', OPENSTACK_EC2API_DB_PASSWORD,
        'rights', list('ALL PRIVILEGES'),
    );
    SELF;
};


#------------------------------------------------------------------------------
# Endpoint configuration script
#------------------------------------------------------------------------------

variable EC2API_ENDPOINTS ?= '/root/sbin/create-ec2api-endpoints.sh';
variable EC2API_ENDPOINTS_CONTENTS ?= file_contents('features/ec2api/templates/create-ec2api-endpoints.templ');

variable EC2API_ENDPOINTS_CONTENTS = replace('EC2API_DOMAIN_NAME',OPENSTACK_EC2API_DOMAIN_NAME,EC2API_ENDPOINTS_CONTENTS);
variable EC2API_ENDPOINTS_CONTENTS = replace('EC2API_PASSWORD',OPENSTACK_EC2API_PASSWORD,EC2API_ENDPOINTS_CONTENTS);
variable EC2API_ENDPOINTS_CONTENTS = replace('EC2API_EMAIL',EC2API_EMAIL,EC2API_ENDPOINTS_CONTENTS);
variable EC2API_ENDPOINTS_CONTENTS = replace('EC2API_PORT',OPENSTACK_EC2API_PORT,EC2API_ENDPOINTS_CONTENTS);
variable EC2API_ENDPOINTS_CONTENTS = replace('EC2API_USERNAME',OPENSTACK_EC2API_USERNAME,EC2API_ENDPOINTS_CONTENTS);
variable EC2API_ENDPOINTS_CONTENTS = replace('EC2API_CONTROLLER_HOST',EC2API_CONTROLLER_HOST,EC2API_ENDPOINTS_CONTENTS);
variable EC2API_ENDPOINTS_CONTENTS = replace('EC2API_MGMT_HOST',EC2API_MGMT_CONTROLLER_HOST,EC2API_ENDPOINTS_CONTENTS);
variable EC2API_ENDPOINTS_CONTENTS = replace('REGION_NAME',OPENSTACK_REGION_NAME,EC2API_ENDPOINTS_CONTENTS);

"/software/components/filecopy/services" = npush(
    escape(EC2API_ENDPOINTS), nlist(
        "config",EC2API_ENDPOINTS_CONTENTS,
        "owner","root",
        "perms","0700",
    ),
);


#------------------------------------------------------------------------------
# ec2api Paste configuration
#------------------------------------------------------------------------------

variable EC2API_API_PASTE ?= '/etc/ec2api/api-paste.ini';

variable EC2API_API_PASTE_CONTENTS ?= file_contents('features/ec2api/templates/api-paste.templ');

"/software/components/filecopy/services" = npush(
    escape(EC2API_API_PASTE), nlist(
        "config",EC2API_API_PASTE_CONTENTS,
        "owner","root",
        "perms","0644",
        "restart", "/sbin/service openstack-ec2api restart",
    ),
);


#------------------------------------------------------------------------------
# Service startup configuration
#------------------------------------------------------------------------------

variable EC2API_SERVICE_FILE ?= '/etc/service-ec2api';
variable EC2API_SERVICE_CONTENTS ?= {
  contents = '';
  foreach(i;service;EC2API_SERVICES) {
      contents = contents + service + "\n";
  };
  contents;
};

"/software/components/filecopy/services" = npush(
    escape(EC2API_SERVICE_FILE), nlist(
        "config",EC2API_SERVICE_CONTENTS,
        "owner","root",
        "perms","0700",
    ),
);

variable EC2API_STARTUP_FILE ?= '/etc/init.d/openstack-ec2api';
variable EC2API_STARTUP_CONTENTS ?= <<EOF;
#!/bin/sh
#
# OpenStack ec2api Services
#
# chkconfig:   - 98 02
# description: ec2api is the EC2 API for Nova
#
### END INIT INFO

SERVICE_LIST=`cat /etc/service-ec2api`

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
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1;; 
esac
exit 0
EOF

"/software/components/filecopy/services" = npush(
    escape(EC2API_STARTUP_FILE), nlist(
        "config",EC2API_STARTUP_CONTENTS,
        "owner","root:root",
        "perms","0755",
    ),
);

include 'components/chkconfig/config';
prefix '/software/components/chkconfig/service';
'openstack-ec2api/on' = '';
'openstack-ec2api/startstop' = true;

include 'components/dirperm/config';
prefix '/software/components/dirperm';
'paths' = {
  SELF[length(SELF)] = dict(
    'path', EC2API_LOG_DIR,
    'owner', 'nova:root',
    'type', 'd',
    'perm', '0755',
  );
  SELF[length(SELF)] = dict(
    'path', EC2API_AUTH_CACHE_DIR,
    'owner', 'nova:root',
    'type', 'd',
    'perm', '0755',
  );
  SELF;
};

