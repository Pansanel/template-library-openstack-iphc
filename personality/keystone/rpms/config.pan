template personality/keystone/rpms/config;

prefix '/software/packages';

'{openstack-keystone}' ?= nlist();
'{python-keystoneclient}' ?= nlist();

'{openssl-devel}' ?= {
    if ( OPENSTACK_CONFIGURE_VOS ) {
        nlist();
    } else {
        null;
    };
};
'{swig}' ?= {
    if ( OPENSTACK_CONFIGURE_VOS ) {
        nlist();
    } else {
        null;
    };
};
'{python-pip}' ?= {
    if ( OPENSTACK_CONFIGURE_VOS ) {
        nlist();
    } else {
        null;
    };
};
