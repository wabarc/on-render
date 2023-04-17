FROM ghcr.io/wabarc/wayback

LABEL org.wabarc.homepage="http://github.com/wabarc" \
      org.wabarc.repository="http://github.com/wabarc/on-render"

ENV BASE_DIR /wayback

WORKDIR ${BASE_DIR}

# Ref: https://wiki.alpinelinux.org/wiki/Fonts
RUN set -o pipefail && \
    apk add --no-cache \
    dbus \
    dumb-init \
    libstdc++ \
    nss \
    ffmpeg \
    chromium \
    harfbuzz \
    freetype \
    ttf-freefont \
    ttf-font-awesome \
    font-noto \
    font-noto-arabic \
    font-noto-emoji \
    font-noto-cjk \
    font-noto-extra \
    font-noto-lao \
    font-noto-myanmar \
    font-noto-thai \
    font-noto-tibetan \
    supervisor \
    ca-certificates \
    py3-setuptools \
    socat \
    libcap \
    you-get \
    rtmpdump \
    youtube-dl \
    libwebp-tools \
 && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

COPY cleaner.sh /
COPY entrypoint.sh /
COPY supervisord.conf /etc/

RUN set -ex; \
    chown wayback:nogroup /var/log/tor; \
    chown wayback:nogroup /var/lib/tor; \
    chmod a+r /etc/supervisord.conf /entrypoint.sh /cleaner.sh; \
    \
    sed -i 's/User/#User/g' /etc/tor/torrc; \
    \
    setcap 'cap_net_bind_service=+ep' /usr/bin/socat

USER wayback

ENV WAYBACK_ONION_LOCAL_PORT=8964
ENV WAYBACK_ONION_REMOTE_PORTS=80,8008
ENV SOCAT_OPTIONS="-d"
ENV PORT=80

EXPOSE 80 443 8008 8964

ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMEDP_DISABLE_GPU=true \
    CHROMEDP_NO_SANDBOX=true \
    CHROMEDP_USER_AGENT="WaybackArchiver/1.0"

ENV WAYBACK_STORAGE_DIR="/tmp/reduxer" \
    WAYBACK_ARGS="-d web"

ENTRYPOINT ["dumb-init", "--"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
