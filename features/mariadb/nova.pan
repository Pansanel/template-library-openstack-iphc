unique template features/mariadb/nova;

include 'components/mysql/config';
prefix '/software/components/mysql/databases';
'nova' = {
  SELF['createDb'] = true;
  SELF['server'] = OPENSTACKNOVA_DB_HOST;
  SELF['users'][OS_NOVA_DB_USERNAME]['password'] = OPENSTACKNOVA_DB_PASSWORD;
  SELF['users'][OS_NOVA_DB_USERNAME]['rights'] = list('ALL PRIVILEGES');
  SELF;
};