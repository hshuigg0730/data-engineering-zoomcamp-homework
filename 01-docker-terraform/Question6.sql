SELECT 
    MAX(t.tip_amount) AS max_amount, 
    zdo."Zone"
FROM green_tripdata_2025_11 t
JOIN zones zpu 
    ON t."PULocationID" = zpu."LocationID"
JOIN zones zdo 
    ON t."DOLocationID" = zdo."LocationID"
WHERE t.lpep_dropoff_datetime >= '2025-11-01' 
  AND t.lpep_dropoff_datetime < '2025-12-01'
  AND zpu."Zone" = 'East Harlem North' 
GROUP BY zdo."Zone"
ORDER BY max_amount DESC
LIMIT 1; 
--81.89	"Yorkville West"