FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV PIP_PACKAGES ansible==2.9.16
ENV APT_PACKAGES locales \
    python-software-properties \
    software-properties-common \
    wget rsyslog systemd curl \
    systemd-cron sudo iproute2 \
    python3 python3-setuptools \
    python3-dev python3-pip build-essential \
    libssl-dev libffi-dev

RUN apt-get update \
    && apt-get install -y --no-install-recommends $APT_PACKAGES \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && rm -rf /var/cache/apt/
RUN curl -sSL https://bootstrap.pypa.io/pip/3.5/get-pip.py -o get-pip.py \
    && python3 get-pip.py \
    && pip3 install --upgrade $PIP_PACKAGES

WORKDIR /root
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf
RUN mkdir -p /usr/share/man/man1 /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts
RUN echo "[defaults]\ninterpreter_python=/usr/bin/python3" > /etc/ansible/ansible.cfg
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
