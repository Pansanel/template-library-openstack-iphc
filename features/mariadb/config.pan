unique template features/mariadb/config;

include 'features/mariadb/rpms/config';

include 'components/chkconfig/config';
prefix '/software/components/chkconfig/service';
'mariadb/on' = '';
'mariadb/startstop' = true;

include 'components/mysql/config';
prefix '/software/components/mysql';

'serviceName' = 'mariadb';

