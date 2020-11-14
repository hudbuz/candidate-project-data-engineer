## Setup

This configuration is built on top of docker/docker-compose. To install docker, follow the instructions here - https://docs.docker.com/engine/install/
This configuration also utilizes the make command. If using windows, you can install make here - http://gnuwin32.sourceforge.net/packages/make.htm; otherwise, you can just run the docker-compose commands listed in the Makefile.


## Instructions

To build the environment, run `make build` or `docker-compose build`

To start the sql container, run `make start` or `docker-compose up -d`

To initialize the db, run `make setup` or `docker-compose exec sqldata  /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U sa -P Pass@word -i ./app/init.sql`

To parse the xml into the Projections_clean table, run `make transform` or `docker-compose exec sqldata /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U sa -P Pass@word -i ./app/projections_clean.sql`

To create the Projections_chart table, run `make chart` or `docker-compose exec sqldata /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U sa -P Pass@word -i ./app/projections_chart.sql`

To remove docker containers and clean the environment, run `make down` or `docker-compose down`

To create an output text file of the Projections_chart table, run `make output`


## Workflow

1. run `make build`
2. run `make start`
3. run `make setup` - note: the previous command sometimes takes a few seconds to complete; if you chain this step with the prior command, wait a few seconds and run again. s
4. run `make transform`
5. run `make chart`
6. run `make output`
