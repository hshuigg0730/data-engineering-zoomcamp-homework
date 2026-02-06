-- Preparation
CREATE OR REPLACE EXTERNAL TABLE `taxi-rides-ny-485916.nytaxi.external_yellow_tripdata_2024`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://nyc-tl-data-hshuigg0730/yellow_2024/yellow_tripdata_2024-*.parquet']
);

CREATE OR REPLACE TABLE taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned AS
SELECT * FROM taxi-rides-ny-485916.nytaxi.external_yellow_tripdata_2024;

-- Question 1
SELECT COUNT(*) FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned;
-- 20332093

-- Question 2
SELECT COUNT(DISTINCT PULocationID) FROM taxi-rides-ny-485916.nytaxi.external_yellow_tripdata_2024; --0B
SELECT COUNT(DISTINCT PULocationID) FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned;--155.12MB

-- Question 3
SELECT  PULocationID FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned;--155.12MB
SELECT  PULocationID,DOLocationID FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned;--310.24MB

-- Question 4
SELECT COUNT(fare_amount) FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned WHERE fare_amount = 0; --8333

-- Question 5
CREATE OR REPLACE TABLE taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_partitioned_clustered
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM taxi-rides-ny-485916.nytaxi.external_yellow_tripdata_2024;

-- Question 6
SELECT DISTINCT VendorID FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned 
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15'; --310.24MB

SELECT DISTINCT VendorID FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_partitioned_clustered 
WHERE DATE(tpep_dropoff_datetime) BETWEEN '2024-03-01' AND '2024-03-15'; --26.84MB

-- Question 9
SELECT count(*) FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_non_partitioned; -- 0B
SELECT count(*) FROM taxi-rides-ny-485916.nytaxi.yellow_tripdata_2024_partitioned_clustered; -- 0B
