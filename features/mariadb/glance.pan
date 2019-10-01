unique template features/mariadb/glance;

include 'components/mysql/config';
prefix '/software/components/mysql/databases';
'glance' = {
  SELF['createDb'] = true;
  SELF['server'] = OPENSTACK_GLANCE_DB_HOST;
  SELF['users'][OS_GLANCE_DB_USERNAME]['password'] = OPENSTACK_GLANCE_DB_PASSWORD;
  SELF['users'][OS_GLANCE_DB_USERNAME]['rights'] = list('ALL PRIVILEGES');
  SELF;
};
