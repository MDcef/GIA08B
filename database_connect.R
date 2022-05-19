library(RODBC)
library(RPostgres)
library(lubridate)
library(dplyr)
library(dbplyr)
library(tidyverse)
library(glue)
library(vmstools)
library(sf)
require (RPostgreSQL); library(DBI)
library(RPostgreSQL)
library(DBI)
library(package)
require(RPostgres)
library(data.table)
library(devtools)


## Connect to GeoFISH

pw <- {"L00k@tF1sh!"}
# loads the PostgreSQL driver
drv <- dbDriver("Postgres")
# creates a connection to the postgres database # note that "con" will be used later in each connection to the database
conn <- dbConnect(drv, 
                  dbname = "geofish", 
                  host = "citprodarcgisdb.postgres.database.azure.com",
                  port = 5432,
                  user = "geofish_viewer@citprodarcgisdb", 
                  password = pw ) #, options = 'ssl_mode=allow')


## When you finish your analysis dont forget to disconnect from GeoFISH
## dbDisconnect(conn)
## dbUnloadDriver(drv)

con1 <- dbConnect(
  Postgres(),
  host = "azsclnxgis01.postgres.database.azure.com",
  dbname = "development_db",
  port = 5432,
  user = "editors_dev@azsclnxgis01",
  password = "Dev!c5374")
