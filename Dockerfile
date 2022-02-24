FROM ubuntu:16.04

LABEL maintainer="bilalcaliskan"
ENV DEBIAN_FRONTEND noninteractive
ENV APT_PACKAGES locales build-essential zlib1g-dev libncurses5-dev \
    libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev \
    libsqlite3-dev wget libbz2-dev software-properties-common \
    wget curl rsyslog systemd systemd-cron sudo iproute2
ENV PIP_PACKAGES pip ansible==2.9.16 pyopenssl

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends $APT_PACKAGES \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean \
    && rm -rf /var/cache/apt/

WORKDIR /opt
RUN wget https://www.python.org/ftp/python/3.9.10/Python-3.9.10.tgz \
    && tar -xf Python-3.9.10.tgz
WORKDIR /opt/Python-3.9.10
RUN ./configure --enable-optimizations
RUN make altinstall
RUN apt-get remove -y python3 \
    && apt-get autoremove -y
RUN ln -s /usr/local/bin/python3.9 /usr/bin/python3

WORKDIR /root
RUN python3 -m pip install --upgrade $PIP_PACKAGES
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf
RUN mkdir -p /usr/share/man/man1 /etc/ansible
RUN echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts
RUN echo "[defaults]\ninterpreter_python=/usr/bin/python3" > /etc/ansible/ansible.cfg
VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]
