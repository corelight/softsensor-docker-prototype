# Base image stage 1 - install anything required to pull down the softsensor binary
FROM debian:10-slim AS stage1

WORKDIR /fakeroot
ARG softsensor_version
RUN chmod 777 /fakeroot \
    && apt-get update && apt-get install -y \
    --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    debian-archive-keyring \
    apt-transport-https

RUN curl -L https://packagecloud.io/corelight/stable/gpgkey | apt-key add - \
    && echo "deb https://packagecloud.io/corelight/stable/debian/ buster main" > /etc/apt/sources.list.d/corelight.list \
    && echo "deb-src https://packagecloud.io/corelight/stable/debian/ buster main" >> /etc/apt/sources.list.d/corelight.list \
    && apt-get update \
    # && apt-get download "corelight-update" \
    && apt-get download "corelight-softsensor=$softsensor_version"


# Base image stage 2 - copy the binary from stage 1, install it, then remove the binary
FROM debian:10-slim AS stage2

COPY --from=stage1 /fakeroot/corelight*  /
COPY . /root/
RUN dpkg -i /corelight-softsensor* \
    # && dpkg -i /corelight-update* \
    && rm /corelight* \
    && chmod +x /root/*.sh

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

RUN python3 -m pip install "zkg" \
    && mkdir /root/.zkg



# squash the image into a single layer
FROM scratch AS final

COPY --from=stage2 / /

CMD [ "/root/startup-script.sh" ]
# ENTRYPOINT ["/opt/corelight/bin/corelight-softsensor"]
# CMD ["start"]
