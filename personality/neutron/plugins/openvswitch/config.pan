template personality/neutron/plugins/openvswitch/config;

# Include Open vSwitch plugin RPMs
include 'personality/neutron/plugins/openvswitch/rpms';

variable TENANT_NETWORK_TYPE ?= 'vlan';
variable BRIDGE_MAPPINGS ?= 'physnet1:br-eth1';
variable NETWORK_VLAN_RANGES ?= 'physnet1:1:4094';

#----------------------------------------------------------------------------- 
# Enable and start Open vSwitch service
#----------------------------------------------------------------------------- 

include 'components/chkconfig/config';

"/software/components/chkconfig/service/openvswitch/on" = "";
"/software/components/chkconfig/service/openvswitch/startstop" = true;

# create link
variable OPENVSWITCH_PLUGIN_CONFIG ?= '/etc/neutron/plugins/ml2/openvswitch_agent.ini';
variable OPENVSWITCH_PLUGIN_CONFIG_CONTENTS ?= file_contents(
    'personality/neutron/plugins/openvswitch/openvswitch_agent.templ')
;
variable OPENVSWITCH_PLUGIN_CONFIG_CONTENTS = {
    contents = SELF;
    contents = replace('TENANT_NETWORK_TYPE', TENANT_NETWORK_TYPE, contents);
    contents = replace('BRIDGE_MAPPINGS', BRIDGE_MAPPINGS, contents);
    contents = replace('NETWORK_VLAN_RANGES', NETWORK_VLAN_RANGES, contents);

    contents;
};

include 'components/filecopy/config';
"/software/components/filecopy/services" = npush(
    escape(OPENVSWITCH_PLUGIN_CONFIG), dict(
        "config", OPENVSWITCH_PLUGIN_CONFIG_CONTENTS,
        "owner", "root:neutron",
        "perms", "0640",
        "restart", "/sbin/service neutron-openvswitch-agent restart",

    ),
);
