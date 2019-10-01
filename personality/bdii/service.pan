# Template defining all the MW components required to run a BDII

unique template personality/bdii/service;

# Define appropriate BDII type if not explicitly done
variable BDII_TYPE ?= 'resource';

# Add BDII rpms
include { 'personality/bdii/rpms' };

# Configure BDII service
include { 'personality/bdii/config' };


# Configure GIP for BDII
include {'features/gip/bdii'};
