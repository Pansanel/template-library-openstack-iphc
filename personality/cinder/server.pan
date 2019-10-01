unique template personality/cinder/server;

variable CINDER_SERVER_SERVICES ?= list('openstack-cinder-api','openstack-cinder-scheduler');
variable CINDER_EMAIL ?= SITE_EMAIL;

# Database related variables
variable CINDER_MYSQL_ADMINUSER ?= 'root';
variable CINDER_MYSQL_ADMINPWD ?= error('CINDER_MYSQL_ADMINPWD required but not specified');


#------------------------------------------------------------------------------
# Mariadb configuration
#------------------------------------------------------------------------------

include  'features/mariadb/config';

'/software/components/mysql/servers/' = {
    SELF[CINDER_MYSQL_SERVER]['adminuser'] = CINDER_MYSQL_ADMINUSER;
    SELF[CINDER_MYSQL_SERVER]['adminpwd'] = CINDER_MYSQL_ADMINPWD;
    SELF;
};

'/software/components/mysql/databases/' = {
    SELF[OPENSTACK_CINDER_DB_NAME]['createDb'] = true;
    SELF[OPENSTACK_CINDER_DB_NAME]['server'] = CINDER_MYSQL_SERVER;
    SELF[OPENSTACK_CINDER_DB_NAME]['users'][OPENSTACK_CINDER_DB_USERNAME] = nlist(
        'password', OPENSTACK_CINDER_DB_PASSWORD,
        'rights', list('ALL PRIVILEGES'),
    );

    SELF;
};


#------------------------------------------------------------------------------
# Endpoint configuration script
#------------------------------------------------------------------------------

variable CINDER_ENDPOINTS ?= '/root/sbin/create-cinder-endpoints.sh';
variable CINDER_ENDPOINTS_CONTENTS ?= file_contents('personality/cinder/templates/create-cinder-endpoints.templ');

variable CINDER_ENDPOINTS_CONTENTS = replace('CINDER_PASSWORD',OPENSTACK_CINDER_PASSWORD,CINDER_ENDPOINTS_CONTENTS);
variable CINDER_ENDPOINTS_CONTENTS = replace('CINDER_EMAIL',CINDER_EMAIL,CINDER_ENDPOINTS_CONTENTS);
variable CINDER_ENDPOINTS_CONTENTS = replace('CINDER_CONTROLLER_HOST',OPENSTACK_CINDER_CONTROLLER_HOST,CINDER_ENDPOINTS_CONTENTS);
variable CINDER_ENDPOINTS_CONTENTS = replace('CINDER_MGMT_HOST',OPENSTACK_CINDER_MGMT_HOST,CINDER_ENDPOINTS_CONTENTS);

"/software/components/filecopy/services" = npush(
    escape(CINDER_ENDPOINTS), nlist(
        "config",CINDER_ENDPOINTS_CONTENTS,
        "owner","root",
        "perms","0700",
    ),
);
