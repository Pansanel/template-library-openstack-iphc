unique template features/mariadb/heat;

include 'components/mysql/config';
prefix '/software/components/mysql/databases';
'heat' = {
  SELF['createDb'] = true;
  SELF['server'] = OPENSTACKHEAT_DB_HOST;
  SELF['users'][OS_HEAT_DB_USERNAME]['password'] = OPENSTACKHEAT_DB_PASSWORD;
  SELF['users'][OS_HEAT_DB_USERNAME]['rights'] = list('ALL PRIVILEGES');
  SELF;
};
