# PostgreSQL 9.4 docker image

A PostgreSQL docker image that supports keeping data and config in separated directories. Currently the relevant directories are hard-coded to:
 - data: `/var/lib/postgresql`
 - config: `etc/postgresql`
 - logfiles: `/var/log/postgres`
 - UNIX sockets: `/var/run/postgresql`

All of these directories are exposed via the `VOLUME` directive in the Dockerfile.

## Operation

If neither a cluster nor config files are found, both will be created. If a cluster is found, but there's no config in `/etc/postgresql`, an attempt is made to extract config from the cluster; if that fails, config is re-created from PostgreSQL defaults found in `/usr/share/postgresql/9.4/` (with appropriate modifications regarding file locations). If there is no cluster, but a config is present in `/etc/postgresql`, a new cluster is created.

## ENV vars

Currently, only these `ENV` vars have any effect:

`POSTGRESS_DB` -- name of the database to be created (*ignored if a cluster is available in `/var/lib/postgresql`*)

`POSTGRESS_USER` -- name of the superuser to be created (*ignored if a cluster is available in `/var/lib/postgresql`, or if the username is `postgres`*)

`POSTGRESS_POSTGRES` -- name of the database to be created (*ignored if a cluster is available in `/var/lib/postgresql`, if not set a random password is generated*)

Licensed under [GNU Affero GPL](https://gnu.org/licenses/agpl.html).

# TODO

 - more complete documentation
 - support for keeping the config *within* the cluster directory
 - more configuration `ENV` vars (data directory, config directory, socket directory, etc)
 - handling `docker-entrypoint-init.d` scripts a'la [the official PostgreSQL docker image](https://github.com/docker-library/postgres/blob/master/9.4/docker-entrypoint.sh#L76)