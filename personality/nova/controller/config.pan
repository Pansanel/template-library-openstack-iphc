template personality/nova/controller/config; 

variable NOVA_EMAIL ?= SITE_EMAIL;
variable NOVA_SERVICES ?= list('openstack-nova-api','openstack-nova-consoleauth','openstack-nova-scheduler','openstack-nova-conductor','openstack-nova-novncproxy');
variable VNCSERVER_LISTEN ?= DB_IP[escape(FULL_HOSTNAME)];

# include configuration common to client and server
include { 'personality/nova/config' };

# Database related variables
variable NOVA_MYSQL_ADMINUSER ?= 'root';
variable NOVA_MYSQL_ADMINPWD ?= error('NOVA_MYSQL_ADMINPWD required but not specified');

#------------------------------------------------------------------------------
# MySQL configuration
#------------------------------------------------------------------------------

include { 'features/mariadb/config' };

'/software/components/mysql/servers/' = {
    SELF[NOVA_MYSQL_SERVER]['adminuser'] = NOVA_MYSQL_ADMINUSER;
    SELF[NOVA_MYSQL_SERVER]['adminpwd'] = NOVA_MYSQL_ADMINPWD;
    SELF;
};

'/software/components/mysql/databases/' = {
    SELF[OPENSTACK_NOVA_DB_NAME]['createDb'] = true;
    SELF[OPENSTACK_NOVA_DB_NAME]['server'] = NOVA_MYSQL_SERVER;
    SELF[OPENSTACK_NOVA_DB_NAME]['users'][OPENSTACK_NOVA_DB_USERNAME] = nlist(
        'password', OPENSTACK_NOVA_DB_PASSWORD,
        'rights', list('ALL PRIVILEGES'),
    );

    SELF[OPENSTACK_NOVA_API_DB_NAME]['createDb'] = true;
    SELF[OPENSTACK_NOVA_API_DB_NAME]['server'] = NOVA_MYSQL_SERVER;
    SELF[OPENSTACK_NOVA_API_DB_NAME]['users'][OPENSTACK_NOVA_DB_USERNAME] = nlist(
        'password', OPENSTACK_NOVA_DB_PASSWORD,
        'rights', list('ALL PRIVILEGES'),
    );

    SELF[OPENSTACK_NOVA_CELL_DB_NAME]['createDb'] = true;
    SELF[OPENSTACK_NOVA_CELL_DB_NAME]['server'] = NOVA_MYSQL_SERVER;
    SELF[OPENSTACK_NOVA_CELL_DB_NAME]['users'][OPENSTACK_NOVA_DB_USERNAME] = nlist(
        'password', OPENSTACK_NOVA_DB_PASSWORD,
        'rights', list('ALL PRIVILEGES'),
    );

    SELF;
};

#------------------------------------------------------------------------------
# Endpoint configuration script
#------------------------------------------------------------------------------

variable NOVA_ENDPOINTS ?= '/root/sbin/create-nova-endpoints.sh';
variable NOVA_ENDPOINTS_CONTENTS ?= file_contents('personality/nova/controller/templates/create-nova-endpoints.templ');

variable NOVA_ENDPOINTS_CONTENTS = replace('NOVA_PASSWORD',OPENSTACK_NOVA_PASSWORD,NOVA_ENDPOINTS_CONTENTS);
variable NOVA_ENDPOINTS_CONTENTS = replace('NOVA_EMAIL',NOVA_EMAIL,NOVA_ENDPOINTS_CONTENTS);
variable NOVA_ENDPOINTS_CONTENTS = replace('NOVA_CONTROLLER_HOST',OPENSTACK_NOVA_CONTROLLER_HOST,NOVA_ENDPOINTS_CONTENTS);
variable NOVA_ENDPOINTS_CONTENTS = replace('NOVA_MGMT_HOST',OPENSTACK_NOVA_MGMT_HOST,NOVA_ENDPOINTS_CONTENTS);

"/software/components/filecopy/services" = npush(
    escape(NOVA_ENDPOINTS), nlist(
        "config",NOVA_ENDPOINTS_CONTENTS,
        "owner","root",
        "perms","0700",
    ),
);
