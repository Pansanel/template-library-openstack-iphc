#!/bin/sh

echo "load variable"
%s
export MAGNUM_URL="http://%s:9511/v1"

export MAGNUM_USER=%s
export MAGNUM_PASSWORD=%s

export MAGNUM_DOMAIN_ADMIN_USER=%s
export MAGNUM_DOMAIN_ADMIN_PASSWORD=%s

echo "[START] Databases configuration"
echo " Container service"
$DEBUG_DATABASES su -s /bin/sh -c "magnum-manage db upgrade" magnum
echo "[DONE] Database configuration"


eco "[START] service configuration"
echo "  Magnum"
$DEBUG_SERVICES quattor_openstack_add_service.sh 'container-infra' "OpenStack Container Infrastructure Management Service" 'magnum'
echo "[END] service configuration"

echo "[START] endpoints configuration"
echo "  Magnum endpoint"
for endpoint_type in $ENDPOINT_TYPES $ADMIN_ENDPOINT_TYPE
do
  $DEBUG_ENDPOINTS quattor_openstack_add_endpoint.sh 'container-infra' $endpoint_type $REGION $MAGNUM_URL
done
echo "[END] endpoints configuration"

echo "[START] Domain configuration"
echo " Domain for Magnum"
$DEBUG_DOMAINS quattor_openstack_add_domain 'magnum' 'Owns users and projects created by magnum'
echo "[END] Domain configuration"

echo "[START] User configuration"
echo "  magnum user [$MAGNUM_USER]"
$DEBUG_USERS quattor_openstack_add_user.sh $MAGNUM_USER $MAGNUM_PASSWORD $OPENSTACK_PROJECT_DOMAIN_ID
$DEBUG_USERS quattor_openstack_add_user.sh $MAGNUM_DOMAIN_ADMIN_USER $MAGNUM_DOMAIN_ADMIN_PASSWORD 'magnum'
echo "[END] User configuration"

echo "[START] Role configuration"
echo "  Role for Magnum"
$DEBUG_USERS_TO_ROLES quattor_openstack_add_user_role.sh $MAGNUM_USER 'admin' 'service'
echo "[END] Role configuration"


