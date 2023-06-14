https://datalemur.com/questions/odd-even-measurements

WITH CTE AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(DAY FROM measurement_time) ORDER BY measurement_time)
    FROM measurements
)
SELECT
    DATE_TRUNC('day', measurement_time::TIMESTAMP),
    SUM(CASE WHEN row_number % 2 <> 0 THEN measurement_value ELSE 0 END) AS odd_sum,
    SUM(CASE WHEN row_number % 2 = 0 THEN measurement_value ELSE 0 END) AS even_sum
FROM CTE
GROUP BY DATE_TRUNC('day', measurement_time::TIMESTAMP)
ORDER BY DATE_TRUNC('day', measurement_time::TIMESTAMP);
