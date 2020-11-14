.PHONY: build
build:
	docker-compose build

.PHONY: start
start:
	docker-compose up -d

.PHONY: setup
setup:
	docker-compose exec sqldata  /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U sa -P Pass@word -i ./app/init.sql

.PHONY: transform
transform:
	docker-compose exec sqldata /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U sa -P Pass@word -i ./app/projections_clean.sql

.PHONY: chart
chart:
	docker-compose exec sqldata /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U sa -P Pass@word -i ./app/projections_chart.sql

.PHONY: output
output:
	docker-compose exec sqldata /opt/mssql-tools/bin/sqlcmd -S 0.0.0.0 -U sa -P Pass@word -Q "SELECT * FROM dbo.Projections_chart;" -o ./app/output.txt -y 30 -Y 30  


.PHONY: down
down:
	docker-compose down
