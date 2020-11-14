## Setup

This configuration is built on top of docker/docker-compose. You can install docker here - https://docs.docker.com/engine/install/

This configuration also utilizes the make command. If using windows, you can install make here - http://gnuwin32.sourceforge.net/packages/make.htm;

Otherwise, you can just run the docker-compose commands listed in the Makefile.


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


# Updates

The implementation of updating the Projections_chart table would be dependent on the manner in which Projections and Actuals receive new/updated data for a given projectionId.

Here are a few scenarios I can imagine:

1. Anytime line item in projection is updated, source data returns entire Projection. In order to safely update projection_chart, catch any line items that may have been dropped/altered between updates, and correctly recalculate Estimated Balance,
you would need to delete the entire projection from the Projection_chart table, and insert the projection with the most recent changes. This workflow would be expensive as you would need to replace the projection each time a month of new data is added, or if updates occur frequently. Heavy read/write and the potential to store multiple copies of the same data.

2. Add a unique identifier to each line item within a projection and some timestamp to indicate time of ingestion/creation. This workflow would allow updates to be continuously appended to the Projections/Actuals table, deduplicated based on time of ingestion/creation, and only replace those records that have been modified. Less read/write, but then the Estimated Balance calculation would be incorrect, requiring recalculation. Alternatively, Estimated balance could be calculated on the fly in the form of a view/materialized view or query, but this could run into performance issues and memory bottlenecks as table increases in size or with high frequency updates. However, period cleaning of the tables to remove duplicate/out of date records after a certain period of time could reduce these performance downsides.


# Alternative Solutions
I chose to execute these transformations in SQL because the source data was provided in the form of an insert script, and I did not want to modify the source data or attempt to parse out the XML. If it were possible to receive the source data in the form of an API call, stream, or s3 file, I would prefer to use a scripting language like python or scala to conduct the workflow of parsing the XML data into the structured format that I desire, and handling inserting/updating into the final table. If the size of the insert data were to significantly increase, performance becomes dependent on the resources available to the SQL instance. In addition, I find parsing in SQL to be a bit cumbersome, as well as losing the ability to test your extraction logic and handle any parsing or data type errors that may arise. Apart from testing and ease of writing code, handling the ingestion and transformation layers outside of SQL would also allow the pipeline to benefit from lazy consumption or streaming, partitioning of source data, and workflow parallelization that would reduce some of the potential performance bottlenecks, increasing durability and introduce the ability to use distributed frameworks like Spark or Hadoop.
