SELECT 
    SUM(t.trip_distance) AS total_amount, 
    zpu."Zone"
FROM green_tripdata_2025_11 t
LEFT JOIN zones zpu 
    ON t."PULocationID" = zpu."LocationID"
WHERE CAST(t.lpep_dropoff_datetime AS DATE) = '2025-11-18'
GROUP BY zpu."Zone"
ORDER BY total_amount DESC;
-- 978.0999999999999	"East Harlem North"