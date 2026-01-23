SELECT COUNT(*) FROM green_tripdata_2025_11 
WHERE lpep_pickup_datetime >= '2025-11-01' AND lpep_pickup_datetime < '2025-12-01' AND trip_distance <= 1
--8007