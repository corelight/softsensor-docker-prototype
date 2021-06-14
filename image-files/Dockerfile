# Base image stage 1 - install anything required to pull down the softsensor binary
FROM debian:10.8-slim AS stage1

WORKDIR /fakeroot
ARG softsensor_version
RUN chmod 777 /fakeroot \
    && apt-get update && apt-get install -y \
    --no-install-recommends \
    curl \
    ca-certificates \
    gpg

RUN curl https://pkgs.corelight.com/signing.pub | gpg --dearmor > /usr/share/keyrings/corelight.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/corelight.gpg] https://pkgs.corelight.com/deb/stable buster main" > /etc/apt/sources.list.d/corelight.list \
    && apt-get update && apt-get download "corelight-softsensor=$softsensor_version"

# Base image stage 2 - copy the binary from stage 1, install it, then remove the binary
FROM debian:10.8-slim AS stage2

ARG zkg_version
ARG suricata_update_version
COPY --from=stage1 /fakeroot/corelight*  /
COPY . /root/
RUN dpkg -i /corelight* \
    && rm /corelight* \
    && chmod +x /root/*.sh \
    && rm -rf /usr/lib/apt/apt.systemd.daily \
    && rm -rf /etc/systemd/system/timers.target.wants/apt-daily-upgrade.timer \
    && rm -rf /etc/systemd/system/timers.target.wants/apt-daily.timer \
    && rm -rf /lib/systemd/system/apt-daily-upgrade.timer \
    && rm -rf /lib/systemd/system/apt-daily.timer \
    && rm -rf /etc/cron.daily/apt-compat \
    && rm -rf /etc/cron.daily/dpkg \
    && rm -rf /etc/cron.daily/passwd

RUN apt-get update && apt-get install -y \
    --no-install-recommends git \
    curl \
    wget \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && python3 -m pip install --upgrade --upgrade-strategy only-if-needed pip \
    && python3 -m pip install j2cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install "suricata-update==$suricata_update_version" \
    && mkdir /etc/suricata

RUN python3 -m pip install "zkg==$zkg_version" \
    && mkdir /root/.zkg



# # Base image stage 3 - final image - squash the image into a single layer
FROM scratch AS final

COPY --from=stage2 / /

LABEL "com.docker.compose.project"="corelight-softsensor-bundle"

# CMD [ "bash" ]
CMD [ "/root/startup-script.sh" ]
