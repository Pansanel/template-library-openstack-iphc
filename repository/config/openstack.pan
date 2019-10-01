unique template repository/config/openstack;
 
include { 'quattor/functions/repository' };

@{
desc = defines the variant of the OpenStack RPM repository to use (typically the OpenStack version).\
The full repository template name will be built appending the version, os, arch. 
values = any string
default = rocky 
required = no
}
variable OPENSTACK_VARIANT ?= 'rocky';

variable REPOSITORY_CMD_ENABLED ?= false;

variable CMD_VARIANT ?= '1';

variable REPOSITORY_OPENSTACK_BASE ?= OPENSTACK_VARIANT + '_' + OS_VERSION_PARAMS['major'] + '_' + PKG_ARCH_DEFAULT;

variable REPOSITORY_EPEL ?= 'epel_' + OS_VERSION_PARAMS['major'] + '_' + PKG_ARCH_DEFAULT;

variable REPOSITORY_VIRT ?= 'virt_' + OS_VERSION_PARAMS['major'] + '_' + PKG_ARCH_DEFAULT;

variable REPOSITORY_CMD_BASE ?= 'cmd_' + CMD_VARIANT + '_' + OS_VERSION_PARAMS['major'] + '_' + PKG_ARCH_DEFAULT + '_base';

variable REPOSITORY_CMD_UPDATES ?= 'cmd_' + CMD_VARIANT + '_' + OS_VERSION_PARAMS['major'] + '_' + PKG_ARCH_DEFAULT + '_updates';

variable YUM_SNAPSHOT_NS ?= 'repository/snapshot';

variable YUM_OS_SNAPSHOT_NS ?= YUM_SNAPSHOT_NS;

variable YUM_OS_SNAPSHOT_DATE ?= if ( is_null(YUM_OS_SNAPSHOT_DATE) ) {
    SELF;
} else {
    YUM_SNAPSHOT_DATE;
};

include 'repository/config/quattor';

variable OPENSTACK_REPOSITORY_LIST ?= {
    SELF[length(SELF)] = REPOSITORY_OPENSTACK_BASE;
    SELF[length(SELF)] = REPOSITORY_VIRT;
    if (REPOSITORY_CMD_ENABLED) {
        SELF[length(SELF)] = REPOSITORY_CMD_BASE;
        SELF[length(SELF)] = REPOSITORY_CMD_UPDATES;
    };

    SELF;
};

'/software/repositories' = {
    add_repositories(OPENSTACK_REPOSITORY_LIST, YUM_OS_SNAPSHOT_NS);
};
