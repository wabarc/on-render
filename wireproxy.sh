#!/bin/sh
#
# Perform wireproxy

interval=60
workdir=/wayback
debug="${DEBUG:-}"
if [ "$debug" = "true" ]; then
  set -x
  workdir=.
fi
config="${workdir}/wg0.conf"

restart() {
  pkill wireproxy

  # Run wireproxy with silent mode in backgound
  wireproxy --silent --config $config > /dev/null 2>&1 &
  sleep 3
}

watch() {
  endpoint='https://cp.cloudflare.com'
  proxy="${PROXY_SERVER}"
  code=204
  timeout=5
  while :; do
    if [ -n "${PROXY_SERVER}" ]; then
      echo 'Running wireproxy watchdog...'
      resp=$(curl -sf --write-out '%{http_code}' --max-time $timeout --proxy "${proxy}" "${endpoint}")
      if [ "${resp}" != "${code}" ]; then
        echo 'Restarting wireproxy...'
        restart
      fi
    fi
    sleep $interval
  done
}

main() {
  # check dependency
  command -v wireproxy > /dev/null || { echo "wireproxy is not installed in this system" 1>&2; exit 0; }

  if [ "${debug}" != "true" ]; then
    printenv WIREPROXY_CONF > /dev/null || { echo "environment variable WIREPROXY_CONF is not found in this system" 1>&2; exit 0; }
    printenv WIREPROXY_CONF > "${config}"
  fi

  restart

  watch
}

main
