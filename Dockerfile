FROM python:3.10.13-alpine3.19
ENV S6_SERVICES_GRACETIME=30000 \
    S6_KILL_GRACETIME=60000 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SYNC_DISKS=1 \
    HOME="/ms" \
    TERM="xterm" \
    PATH=${PATH}:/usr/lib/chromium \
    LANG="C.UTF-8" \
    TZ="Asia/Shanghai" \
    PS1="\u@\h:\w \$ " \
    PUID=0 \
    PGID=0 \
    UMASK=000 \
    WORKDIR="/media-saber"
RUN apk add --no-cache --virtual .build-deps \
        libffi-dev \
        gcc \
        musl-dev \
        libxml2-dev \
        libxslt-dev \
    && apk add --no-cache $(echo $(wget --no-check-certificate -qO- https://raw.githubusercontent.com/xylplm/media-saber-base/master/package_list.txt)) \
    && curl https://rclone.org/install.sh | bash \
    && if [ "$(uname -m)" = "x86_64" ]; then ARCH=amd64; elif [ "$(uname -m)" = "aarch64" ]; then ARCH=arm64; fi \
    && curl https://dl.min.io/client/mc/release/linux-${ARCH}/mc --create-dirs -o /usr/bin/mc \
    && chmod +x /usr/bin/mc \
    && pip install --upgrade pip setuptools wheel \
    && pip install cython \
    && pip install -r https://raw.githubusercontent.com/xylplm/media-saber-base/master/requirements.txt \
    && apk del --purge .build-deps \
    && rm -rf /tmp/* /ms/.cache /var/cache/apk/*
WORKDIR ${WORKDIR}
RUN addgroup -S ms -g 911 \
    && adduser -S ms -G ms -h ${HOME} -s /bin/bash -u 911 \
    && python_ver=$(python3 -V | awk '{print $2}') \
    && echo "${WORKDIR}/" > /usr/local/lib/python${python_ver%.*}/site-packages/media-saber.pth \
    && echo 'fs.inotify.max_user_watches=5242880' >> /etc/sysctl.conf \
    && echo 'fs.inotify.max_user_instances=5242880' >> /etc/sysctl.conf \
    && echo "ms ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
ENTRYPOINT [ "/init" ]