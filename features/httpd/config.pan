unique template features/httpd/config;

variable OIDC_CLIENTID ?= 'oidc_clientid';
variable OIDC_CLIENTSECRET ?= 'changeme';
variable OIDC_CRYPTOPASSPHRASE ?= 'changeme';
variable OIDC_REDIRECTURL ?= KEYSTONE_PUBLIC_ENDPOINT + '/auth/OS-FEDERATION/websso/openid/redirect';

include 'features/httpd/rpms/config';

include 'components/chkconfig/config';
prefix '/software/components/chkconfig/service';
'httpd/on' = '';
'httpd/startstop' = true;

include 'components/metaconfig/config';

prefix '/software/components/metaconfig/services/{/etc/httpd/conf.d/wsgi-keystone.conf}';
'module' = 'apache-keystone';
'daemons/httpd' = 'restart';
'contents/listen' = list(5000, 35357);

'contents/vhosts/0/server' = OPENSTACK_KEYSTONE_CONTROLLER_HOST;
'contents/vhosts/0/port' = 5000;
'contents/vhosts/0/processgroup' = 'keystone-public';
'contents/vhosts/0/script' = '/usr/bin/keystone-wsgi-public';
'contents/vhosts/0/oidc' = {
  SELF['clientid'] = OIDC_CLIENTID;
  SELF['clientsecret'] = OIDC_CLIENTSECRET;
  SELF['cryptopassphrase'] = OIDC_CRYPTOPASSPHRASE;
  SELF['redirecturi'] = OIDC_REDIRECTURL;
  SELF;
};
'contents/vhosts/0/ssl' = if (OPENSTACK_SSL) {
  SELF['cert'] = OPENSTACK_SSL_CERT;
  SELF['key'] = OPENSTACK_SSL_KEY;
  if (exists(OPENSTACK_SSL_CHAIN)) {
    SELF['chain'] = OPENSTACK_SSL_CHAIN;
  };
  SELF;
} else {
  null;
};

'contents/vhosts/1/server' = OPENSTACK_KEYSTONE_MGMT_HOST;
'contents/vhosts/1/port' = 35357;
'contents/vhosts/1/processgroup' = 'keystone-admin';
'contents/vhosts/1/oidc' = {
  SELF['clientid'] = OIDC_CLIENTID;
  SELF['clientsecret'] = OIDC_CLIENTSECRET;
  SELF['cryptopassphrase'] = OIDC_CRYPTOPASSPHRASE;
  SELF['redirecturi'] = OIDC_REDIRECTURL;
  SELF;
};
'contents/vhosts/1/script' = '/usr/bin/keystone-wsgi-admin';
'contents/vhosts/1/ssl' = if (OPENSTACK_SSL) {
  SELF['cert'] = OPENSTACK_MGMT_SSL_CERT;
  SELF['key'] = OPENSTACK_MGMT_SSL_KEY;
  if (exists(OPENSTACK_MGMT_SSL_CHAIN)) {
    SELF['chain'] = OPENSTACK_MGMT_SSL_CHAIN;
  };
  SELF;
} else {
  null;
};

'contents/vhosts/2/server' = OPENSTACK_KEYSTONE_MGMT_HOST;
'contents/vhosts/2/port' = 5000;
'contents/vhosts/2/processgroup' = 'keystone-internal';
'contents/vhosts/2/oidc' = {
  SELF['clientid'] = OIDC_CLIENTID;
  SELF['clientsecret'] = OIDC_CLIENTSECRET;
  SELF['cryptopassphrase'] = OIDC_CRYPTOPASSPHRASE;
  SELF['redirecturi'] = OIDC_REDIRECTURL;
  SELF;
};
'contents/vhosts/2/script' = '/usr/bin/keystone-wsgi-public';
'contents/vhosts/2/ssl' = if (OPENSTACK_SSL) {
  SELF['cert'] = OPENSTACK_MGMT_SSL_CERT;
  SELF['key'] = OPENSTACK_MGMT_SSL_KEY;
  if (exists(OPENSTACK_MGMT_SSL_CHAIN)) {
    SELF['chain'] = OPENSTACK_MGMT_SSL_CHAIN;
  };
  SELF;
} else {
  null;
};

include 'components/filecopy/config';
prefix '/software/components/filecopy/services/{/usr/share/templates/quattor/metaconfig/apache-keystone.tt}';
'config' = file_contents('features/httpd/metaconfig/apache-keystone.tt');
'perms' = '0644';
