WITH cohort_base AS (
    SELECT 
        user_id,
        MIN(transaction_date) AS cohort_date
    FROM transactions
    GROUP BY user_id
),

cohort_calc AS (
    SELECT 
        t.user_id,
        DATE_FORMAT(c.cohort_date, '%Y-%m') AS cohort_month,
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS transaction_month,
        TIMESTAMPDIFF(MONTH, c.cohort_date, t.transaction_date) AS cohort_index
    FROM transactions t
    JOIN cohort_base c
    ON t.user_id = c.user_id
),

retention_data AS (
    SELECT 
        cohort_month,
        cohort_index,
        COUNT(DISTINCT user_id) AS users_count
    FROM cohort_calc
    GROUP BY cohort_month, cohort_index
),

final_retention AS (
    SELECT 
        *,
        FIRST_VALUE(users_count) OVER (
            PARTITION BY cohort_month 
            ORDER BY cohort_index
        ) AS cohort_size,
        
        ROUND(
            users_count * 100.0 / FIRST_VALUE(users_count) OVER (
                PARTITION BY cohort_month 
                ORDER BY cohort_index
            ), 2
        ) AS retention_rate
    FROM retention_data
)

SELECT 
    cohort_month,
    MAX(CASE WHEN cohort_index = 0 THEN retention_rate END) AS M0,
    MAX(CASE WHEN cohort_index = 1 THEN retention_rate END) AS M1,
    MAX(CASE WHEN cohort_index = 2 THEN retention_rate END) AS M2,
    MAX(CASE WHEN cohort_index = 3 THEN retention_rate END) AS M3
FROM final_retention
GROUP BY cohort_month
ORDER BY cohort_month;
