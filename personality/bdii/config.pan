unique template personality/bdii/config;

# Include base configuration for GIP
include { 'features/gip/env' };

# Port used by BDII
variable BDII_PORT ?= 2170;

# BDII directories and files
variable BDII_LOCATION_VAR ?= '/var/lib/bdii';
variable BDII_LOG_FILE ?= '/var/log/bdii/bdii-update.log';
variable BDII_LOG_LEVEL ?= 'ERROR';

variable BDII_USER ?= 'ldap';
variable BDII_GROUP ?= BDII_USER;

# Time to wait for completion of a ldap request
variable BDII_READ_TIMEOUT ?= 300;

# This filter only affects search done directly by BDII, not those done by GIP.
variable BDII_SEARCH_FILTER  ?= '*';

variable BDII_BREATHE_TIME ?= 120;

# The number of updates that the changes should be logged
variable BDII_ARCHIVE_SIZE ?= 0;

#variable BDII_MODIFY_DN ?= false;

variable BDII_FIX_GLUE ?= 'yes';

variable BDII_MDS_VO_NAME ?= 'Glue2GroupID=cloud,o=glue';

variable RESOURCE_INFORMATION_URL = 'ldap://'+FULL_HOSTNAME+':'+to_string(BDII_PORT)+'/' + BDII_MDS_VO_NAME;

variable BDII_SLAPD_CONF_FILE ?= '/etc/bdii/bdii-slapd.conf';

# ----------------------------------------------------------------------------
# chkconfig
# ----------------------------------------------------------------------------
include { 'components/chkconfig/config' };
"/software/components/chkconfig/service/bdii/on" = "";
"/software/components/chkconfig/dependencies/pre" = push("lcgbdii");

# ----------------------------------------------------------------------------
# accounts
# If BDII_TYPE=resource, take care of defining GIP user to match BDII_USER and
# updating GIP configuration, if already done.
#
# Also add BDII_USER to glite group to ensure it has access to GLITE_LOCATION_VAR.
# ----------------------------------------------------------------------------
include { 'users/' + BDII_USER };
"/software/components/lcgbdii/dependencies/pre" = push("accounts");


variable BDII_DELETE_DELAY ?= 0;

# -----------------------------------------------------------------------------
# lcgbdii configuration
# -----------------------------------------------------------------------------
include { 'components/lcgbdii/config' };
'/software/components/lcgbdii/archiveSize' = BDII_ARCHIVE_SIZE;
'/software/components/lcgbdii/breatheTime' = BDII_BREATHE_TIME;
'/software/components/lcgbdii/configFile' = '/etc/bdii/bdii.conf';
'/software/components/lcgbdii/deleteDelay' = BDII_DELETE_DELAY;
'/software/components/lcgbdii/ldifDir' = GIP_LDIF_DIR;
'/software/components/lcgbdii/logFile' = BDII_LOG_FILE;
'/software/components/lcgbdii/logLevel' = BDII_LOG_LEVEL;
'/software/components/lcgbdii/pluginDir' = GIP_PLUGIN_DIR;
'/software/components/lcgbdii/port' = BDII_PORT;
'/software/components/lcgbdii/providerDir' = GIP_PROVIDER_DIR;
'/software/components/lcgbdii/readTimeout' = BDII_READ_TIMEOUT;
'/software/components/lcgbdii/slapdConf' = '/etc/bdii/bdii-slapd.conf';
'/software/components/lcgbdii/user' = BDII_USER;
'/software/components/lcgbdii/varDir' = BDII_LOCATION_VAR;
