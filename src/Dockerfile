FROM debian:buster-slim

# Debian Base to use
ENV DEBIAN_VERSION buster

# initial install of av daemon
RUN echo "deb http://http.debian.net/debian/ $DEBIAN_VERSION main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://http.debian.net/debian/ $DEBIAN_VERSION-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/ $DEBIAN_VERSION/updates main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -qq \
    clamav-daemon \
    clamav-freshclam \
    clamdscan \
    libclamunrar9 \
    wget && \
    apt-get clean && \
    apt-get install ca-certificates openssl && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/clamav && \
    useradd clamav_user -G clamav -u 1000 -s /var/lib/clamav && \
    chown -R clamav_user:clamav /var/lib/clamav
# permission juggling
RUN mkdir -p /var/run/clamav && \
    chown clamav_user:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav && \
    chown -R clamav_user:clamav /var/log/clamav/  /etc/clamav /var/run/clamav
# initial update of av databases
# RUN wget -O /var/lib/clamav/main.cvd http://database.clamav.net/main.cvd && \
#     wget -O /var/lib/clamav/daily.cvd http://database.clamav.net/daily.cvd && \
#     wget -O /var/lib/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd && \
#     chown clamav_user:clamav/var/lib/clamav/*.cvd

# av configuration update
RUN sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/clamd.conf && \
    echo "TCPSocket 3310" >> /etc/clamav/clamd.conf && \
    if ! [ -z $HTTPProxyServer ]; then echo "HTTPProxyServer $HTTPProxyServer" >> /etc/clamav/freshclam.conf; fi && \
    if ! [ -z $HTTPProxyPort   ]; then echo "HTTPProxyPort $HTTPProxyPort" >> /etc/clamav/freshclam.conf; fi && \
    sed -i 's/^Foreground .*$/Foreground true/g' /etc/clamav/freshclam.conf





# port provision
EXPOSE 3310

COPY freshclam.conf /etc/clamav/freshclam.conf
COPY clamd.conf /etc/clamav/clamd.conf

COPY bootstrap.sh /
COPY check.sh /
COPY --chown=clamav_user:clamav eicar.com /
COPY --chown=clamav_user:clamav ./readyness.sh /

RUN chown clamav_user:clamav /etc/ssl/certs

RUN chown clamav_user:clamav bootstrap.sh check.sh /etc/clamav /etc/clamav/clamd.conf /etc/clamav/freshclam.conf /var/log/clamav/clamav.log /var/log/clamav/freshclam.log && \
    chmod u+x bootstrap.sh check.sh

USER 1000

CMD ["/bootstrap.sh"]
