#!/bin/sh
#
# Perform wireproxy

# check dependency
command -v wireproxy > /dev/null || { echo "wireproxy is not installed in this system" 1>&2; exit 0; }
printenv WIREPROXY_CONF > /dev/null || { echo "environment variable WIREPROXY_CONF is not found in this system" 1>&2; exit 0; }

homedir=/wayback
config="${homedir}/wireproxy.conf"

printenv WIREPROXY_CONF > "${config}"

wireproxy -c "${config}"
