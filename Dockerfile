FROM ubuntu:16.04

ENV PIP_PACKAGES ansible pyopenssl
ENV APT_PACKAGES locales \
    python-software-properties \
    software-properties-common \
    python-setuptools \
    wget rsyslog systemd systemd-cron sudo iproute2 python-pip

RUN apt-get update \
    && apt-get install -y --no-install-recommends $APT_PACKAGES \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && rm -rf /var/cache/apt/
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN pip install $PIP_PACKAGES

RUN mkdir -p /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
