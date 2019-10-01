unique template features/httpd/rpms/config;

prefix '/software/packages';
'httpd' ?= dict();
'{mod_wsgi}' ?= dict();
'{mod_ssl}' ?= {
  if ( OPENSTACK_SSL ) {
    dict();
  } else {
    null;
  }
};

'{mod_auth_openidc}' ?= {
    if (OPENSTACK_OPENID) {
    dict();
  } else {
    null;
  }
};
