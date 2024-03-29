unique template features/mariadb/cinder;

include 'components/mysql/config';
prefix '/software/components/mysql/databases';
'cinder' = {
  SELF['createDb'] = true;
  SELF['server'] = OPENSTACK_CINDER_DB_HOST;
  SELF['users'][OS_CINDER_DB_USERNAME]['password'] = OPENSTACK_CINDER_DB_PASSWORD;
  SELF['users'][OS_CINDER_DB_USERNAME]['rights'] = list('ALL PRIVILEGES');
  SELF;
};
