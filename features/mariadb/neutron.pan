unique template features/mariadb/neutron;

include 'components/mysql/config';
prefix '/software/components/mysql/databases';
'neutron' = {
  SELF['createDb'] = true;
  SELF['server'] = OPENSTACKNEUTRON_DB_HOST;
  SELF['users'][OS_NEUTRON_DB_USERNAME]['password'] = OPENSTACKNEUTRON_DB_PASSWORD;
  SELF['users'][OS_NEUTRON_DB_USERNAME]['rights'] = list('ALL PRIVILEGES');
  SELF;
};