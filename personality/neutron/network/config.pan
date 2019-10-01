# Template configuring Neutron network node

unique template personality/neutron/network/config;

variable NEUTRON_SERVICES ?= list(
    'neutron-openvswitch-agent',
    'neutron-dhcp-agent',
    'neutron-metadata-agent',
    'neutron-l3-agent',
);
variable NEUTRON_NODE_TYPE ?= 'network';
variable METADATA_IP ?= OPENSTACK_NOVA_MGMT_IP;
variable NOVA_METADATA_PORT ?= '8775';
variable NOVA_METADATA_IP ?= OPENSTACK_NOVA_MGMT_IP;

# include configuration common to client and server
include 'personality/neutron/config';


#----------------------------------------------------------------------------
# Define several sysctl variables for the networking
#----------------------------------------------------------------------------

include 'components/sysctl/config';

'/software/components/sysctl/variables/net.ipv4.ip_forward' = '1';
'/software/components/sysctl/variables/net.ipv4.conf.all.rp_filter' = '0';
'/software/components/sysctl/variables/net.ipv4.conf.default.rp_filter' = '0';


#----------------------------------------------------------------------------
# DHCP Agent configuration
#----------------------------------------------------------------------------

variable DHCP_AGENT_CONFIG ?= '/etc/neutron/dhcp_agent.ini';
variable DHCP_AGENT_CONFIG_CONTENTS ?= file_contents('personality/neutron/network/templates/dhcp_agent.templ');

include 'components/filecopy/config';

"/software/components/filecopy/services" = npush(
    escape(DHCP_AGENT_CONFIG), dict(
        "config", DHCP_AGENT_CONFIG_CONTENTS,
        "owner", "root:neutron",
        "perms", "0640",
        "restart", "/sbin/service neutron-dhcp-agent restart",
    ),
);


#----------------------------------------------------------------------------
# L3 Agent configuration
#----------------------------------------------------------------------------

variable L3_AGENT_INI ?= '/etc/neutron/l3_agent.ini';
variable L3_AGENT_INI_CONTENTS ?= file_contents('personality/neutron/network/templates/l3_agent.templ');

variable L3_AGENT_INI_CONTENTS = {
    contents = SELF;
    contents = replace('METADATA_IP', METADATA_IP, contents);
    contents = replace('KEYSTONE_URI', KEYSTONE_MGMT_ENDPOINT, contents);
    contents = replace('NEUTRON_TENANT', OPENSTACK_NEUTRON_TENANT, contents);
    contents = replace('NEUTRON_USERNAME', OPENSTACK_NEUTRON_USERNAME, contents);
    contents = replace('NEUTRON_PASSWORD', OPENSTACK_NEUTRON_PASSWORD, contents);
    contents;
};

"/software/components/filecopy/services" = npush(
    escape(L3_AGENT_INI), dict(
        "config", L3_AGENT_INI_CONTENTS,
        "owner", "root:neutron",
        "perms", "0640",
        "restart", "/sbin/service neutron-l3-agent restart",
    ),
);


#----------------------------------------------------------------------------
# Metadata Agent configuration
#----------------------------------------------------------------------------

variable METADATA_AGENT_INI ?= '/etc/neutron/metadata_agent.ini';
variable METADATA_AGENT_INI_CONTENTS ?= file_contents('personality/neutron/network/templates/metadata_agent.templ');

variable METADATA_AGENT_INI_CONTENTS = {
    contents = SELF;
    contents = replace('KEYSTONE_URI', KEYSTONE_MGMT_ENDPOINT, contents);
    contents = replace('REGION_NAME', OPENSTACK_REGION_NAME, contents);
    contents = replace('NEUTRON_TENANT', OPENSTACK_NEUTRON_TENANT, contents);
    contents = replace('NEUTRON_USERNAME', OPENSTACK_NEUTRON_USERNAME, contents);
    contents = replace('NEUTRON_PASSWORD', OPENSTACK_NEUTRON_PASSWORD, contents);
    contents = replace('NOVA_METADATA_IP', NOVA_METADATA_IP, contents);
    contents = replace('NOVA_METADATA_PORT', NOVA_METADATA_PORT, contents);
    contents = replace('METADATA_PROXY_SHARED_SECRET', METADATA_PROXY_SHARED_SECRET, contents);
    contents;
};

"/software/components/filecopy/services" = npush(
    escape(METADATA_AGENT_INI), dict(
        "config", METADATA_AGENT_INI_CONTENTS,
        "owner", "root:neutron",
        "perms", "0640",
        "restart", "/sbin/service neutron-metadata-agent restart",
    ),
);
