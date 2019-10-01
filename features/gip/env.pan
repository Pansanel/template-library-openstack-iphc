# Template defining GIP environment (directory layout).
# Used by other GIP configuration templates to limit dependencies between templates

unique template features/gip/env;

# GIP_BASE_DIR is the directory containing /ldif, /plugin, ...
variable GIP_BASE_DIR ?= '/var/lib/bdii/gip';

# Location of configuration files for GIP scripts
variable GIP_SCRIPTS_CONF_DIR ?= '/etc/bdii/gip';

# Location of LDIF files
variable GIP_LDIF_DIR ?= GIP_BASE_DIR + '/ldif';

# Location of GIP plugins
variable GIP_PLUGIN_DIR  ?= GIP_BASE_DIR + '/plugin';

# Location of GIP providers
variable GIP_PROVIDER_DIR = GIP_BASE_DIR + '/provider';

# Location of GIP cache
variable GIP_CACHE_DIR ?= GIP_BASE_DIR + '/cache/gip';

# Location of temporary files
variable GIP_TMP_DIR ?= GIP_BASE_DIR + '/tmp/gip';
