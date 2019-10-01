unique template features/gip/openstack;

# ---------------------------------------------------------------------------- 
# Glue 2 configuration
# ---------------------------------------------------------------------------- 
include 'components/gip2/config';
variable GIP_PROVIDER_SCRIPT ?= 'cloud-info-provider';
variable GIP_PROVIDER_CONTENTS ?= {
    contents = '#!/bin/sh' + "\n";
    contents = contents + '/usr/bin/cloud-info-provider-service \' + "\n";
    contents = contents + '    --yaml /etc/cloud-info-provider/bdii.yaml \' + "\n";
    contents = contents + '    --middleware openstack \' + "\n";
    contents = contents + '    --template-dir /etc/cloud-info-provider/templates \' + "\n";
    contents = contents + '    --os-username ' + OPENSTACK_USERNAME + ' \' + "\n";
    contents = contents + '    --os-password ' + OPENSTACK_PASSWORD + ' \' + "\n";
    contents = contents + '    --os-project-name ' + OPENSTACK_PROJECT + ' \' + "\n";
    contents = contents + '    --os-user-domain-name Default \' + "\n";
    contents = contents + '    --os-project-domain-name Default \' + "\n";
    contents = contents + '    --os-cacert /etc/grid-security/certificates \' + "\n";
    contents = contents + '    --os-auth-url ' + KEYSTONE_CONTROLLER_AUTH + '/v3';

  contents;
};

"/software/components/gip2/provider" = {
    if ( exists(SELF) && is_defined(SELF) && !is_dict(SELF) ) {
        error('/software/components/gip2/provider must be a dict');
    };

    SELF[GIP_PROVIDER_SCRIPT] = GIP_PROVIDER_CONTENTS;
    SELF;
};
