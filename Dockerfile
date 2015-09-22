#
# based on the example Dockerfile for http://docs.docker.com/examples/postgresql_service/
#

FROM debian:jessie
MAINTAINER Michał "rysiek" Woźniak <rysiek@hackerspace.pl>

# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main 9.4' > /etc/apt/sources.list.d/pgdg.list

# install postgres and other needed things
# we do not want the default "main' cluster, though, we're going to create our own! wee!
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y postgresql-common --no-install-recommends && \
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf && \
    apt-get install -y \
        locales \
        python-software-properties \
        software-properties-common \
        postgresql-9.4 \
        postgresql-client-9.4 \
        postgresql-contrib-9.4 \
         --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# make sure all the required directories exist
RUN mkdir -p /var/run/postgresql && chown -R postgres:postgres /var/run/postgresql
RUN mkdir -p /var/lib/postgresql && chown -R postgres:postgres /var/lib/postgresql
RUN mkdir -p /etc/postgresql
# clear the data dir just in case
RUN rm -rf /var/lib/postgresql/*

# prep script -- will be run each time the container is started
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

# Expose the PostgreSQL port
EXPOSE 5432
ENV PATH /usr/lib/postgresql/9.4/bin/:$PATH

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/var/lib/postgresql/", "/var/run/postgresql", "/etc/postgresql", "/var/log/postgresql"]

# Set the default command to run when starting the container
ENTRYPOINT ["/entrypoint.sh"]
# we want config and data in separate directories, hence:
# http://www.postgresql.org/docs/9.4/static/runtime-config-file-locations.html
# oh, and we want postgres to listen on UNIX sockets in /var/run/postgresql
CMD ["postgres", "-D", "/etc/postgresql", "--data-directory=/var/lib/postgresql/", "-k", "/var/run/postgresql"]