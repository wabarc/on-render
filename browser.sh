#!/bin/sh
#
# Perform chromium

if [ "${DEBUG}" = "yes" ]; then
    set -x
fi
if [ "${NO_BROWSER}" = "yes" ]; then
    exit 0
fi

# check dependency
command -v chromium-browser > /dev/null || { echo "chromium is not installed in this system" 1>&2; exit 1; }

# More flag details see: https://peter.sh/experiments/chromium-command-line-switches/
args="--headless=new \
    --disable-gpu \
    --no-sandbox \
    --remote-debugging-address=0.0.0.0 \
    --remote-debugging-port=9222 \
    --disable-dev-shm-usage \
    --disable-translate \
    --disable-extensions \
    --disable-software-rasterizer \
    --disable-sync \
    --disable-default-apps \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-background-timer-throttling \
    --ignore-certificate-errors \
    --use-fake-ui-for-media-stream \
    --use-gl=swiftshader \
    --hide-scrollbars \
    --mute-audio \
    --no-default-browser-check \
    --no-first-run"

if [ -n "${CHROMEDP_USER_AGENT}" ]; then
    args="${args} --user-agent=${CHROMEDP_USER_AGENT}"
fi
if [ -n "${PROXY_SERVER}" ]; then
    args="${args} --proxy-server=${PROXY_SERVER}"
fi

chromium-browser $args
