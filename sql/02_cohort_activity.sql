WITH cohort_base AS (
    SELECT 
        user_id,
        MIN(transaction_date) AS cohort_date
    FROM transactions
    GROUP BY user_id
),

    SELECT 
        t.user_id,
        DATE_FORMAT(c.cohort_date, '%Y-%m') AS cohort_month,
        DATE_FORMAT(t.transaction_date, '%Y-%m') AS transaction_month,
        TIMESTAMPDIFF(MONTH, c.cohort_date, t.transaction_date) AS cohort_index
    FROM transactions t
    JOIN cohort_base c
    ON t.user_id = c.user_id;
