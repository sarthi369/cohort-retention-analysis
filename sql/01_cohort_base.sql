    SELECT 
        user_id,
        MIN(transaction_date) AS cohort_date
    FROM transactions
    GROUP BY user_id;
