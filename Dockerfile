FROM debian:buster-slim

ARG APP_VERSION
ARG APP_HASH
ARG BUILD_DATE
# If stable argument is passed it will download stable instead of beta
ARG STABLE

LABEL org.label-schema.version=$APP_VERSION \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$APP_HASH \
      org.label-schema.vcs-url="https://github.com/mgrafr/domoticz_mg" \
      org.label-schema.url="https://domoticz.com/" \
      org.label-schema.vendor="Domoticz" \
      org.label-schema.name="Domoticz_mg" \
      org.label-schema.description="Domoticz open source Home Automation system" \
      org.label-schema.license="GPLv3" \
      org.label-schema.docker.cmd="docker run -v ./config:/config -v ./plugins:/opt/domoticz_mg/plugins -e DATABASE_PATH=/config/domoticz.db -p 8086:8080 -d domoticz/domoticz_mg" \
      maintainer="Domoticz Docker Maintainers <info@domoticz.com>"

WORKDIR /opt/domoticz_mg

ARG DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        tzdata \
        unzip \
        git \
        libudev-dev \
        libusb-0.1-4 \
        libsqlite3-0 \
        curl libcurl4 libcurl4-gnutls-dev \
        libpython3.7-dev \
        python3 \
        python3-pip \
    && OS="$(uname -s | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/')" \
    && MACH=$(uname -m) \
    && if [ ${MACH} = "armv6l" ]; then MACH = "armv7l"; fi \
    && archive_file="domoticz_${OS}_${MACH}.tgz" \
    && version_file="version_${OS}_${MACH}.h" \
    && history_file="history_${OS}_${MACH}.txt" \
    && if [ -z "$STABLE"]; then curl -k -L https://releases.domoticz.com/releases/beta/${archive_file} --output domoticz.tgz; else curl -k -L https://releases.domoticz.com/releases/release/${archive_file} --output domoticz.tgz; fi \
    && tar xfz domoticz.tgz \
    && rm domoticz.tgz \
    && mkdir -p /opt/domoticz_mg/userdata \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && pip3 install setuptools requests \
	&& pip3 install fabric \

VOLUME /opt/domoticz_mg/userdata

EXPOSE 8080
EXPOSE 6144
EXPOSE 443

ENV LOG_PATH=
ENV DATABASE_PATH=
ENV WWW_PORT=8080
ENV SSL_PORT=443
ENV EXTRA_CMD_ARG=

# timezone env with default
ENV TZ=Europe/Paris

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/opt/domoticz_mg/domoticz"]
