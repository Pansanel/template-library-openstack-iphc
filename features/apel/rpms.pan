unique template features/apel/rpms;

prefix '/software/packages';

# Dependencies for cASO
'{python-ceilometerclient}' ?= nlist();
'{python-dirq}' ?= nlist();
'{python2-positional}' ?= nlist();
'{caso}' ?= nlist();

# Dependencies for Apel SSM
'{stomppy}' ?= nlist();
'{python-daemon}' ?= nlist();
'{python-ldap}' ?= nlist();
'{apel-ssm}' ?= nlist();
