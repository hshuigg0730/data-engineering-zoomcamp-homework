SELECT 
    CAST(lpep_dropoff_datetime AS DATE) AS "day", 
    MAX(trip_distance) AS max_distance
FROM green_tripdata_2025_11 
WHERE 
    CAST(lpep_dropoff_datetime AS DATE) IN ('2025-11-14', '2025-11-20', '2025-11-23', '2025-11-25') 
    AND trip_distance < 100
GROUP BY "day"
ORDER BY max_distance DESC;
--"2025-11-14"	88.03