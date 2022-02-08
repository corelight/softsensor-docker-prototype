FROM public.ecr.aws/corelight/software-sensor:1.4.0-59-g0f8de8b

# The following COPY and RUN commands will install optionally install
# zkg for open source zeek packages and some optional bash scripts
COPY . /root/
RUN chmod +x /root/*.sh \
    && apt-get update && apt-get install -y \
    --no-install-recommends git \
    curl \
    wget \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    && python3 -m pip install --upgrade --upgrade-strategy only-if-needed pip

RUN python3 -m pip install "zkg" \
    && mkdir /root/.zkg


CMD [ "/root/startup-script.sh" ]
# ENTRYPOINT ["/opt/corelight/bin/corelight-softsensor"]
# CMD ["start"]
