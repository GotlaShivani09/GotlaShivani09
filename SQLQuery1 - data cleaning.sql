select * from [dbo].[fraud_detection_dataset raw]

select * from [dbo].[fraud_detection_dataset raw]
where transaction_id is not null
and customer_id is not null
and customer_age is not null
and merchant_id is not null
and transaction_date IS NOT NULL
AND fraud_detected IS NOT NULL;

  -- Impute missing values for transaction_amount
UPDATE [dbo].[fraud_detection_dataset raw]
SET transaction_amount = (
    SELECT AVG(transaction_amount)
    FROM [dbo].[fraud_detection_dataset raw]
    WHERE transaction_amount IS NOT NULL
)
WHERE transaction_amount IS NULL;

-- Impute missing values for fraud_loss_amount
UPDATE [dbo].[fraud_detection_dataset raw]
SET fraud_loss_amount = (
    SELECT AVG(fraud_loss_amount)
    FROM [dbo].[fraud_detection_dataset raw]
    WHERE fraud_loss_amount IS NOT NULL
)
WHERE fraud_loss_amount IS NULL;

-- Impute missing values for transaction volume
update [dbo].[fraud_detection_dataset raw]
set transaction_volume =(
    SELECT AVG(transaction_volume)
    FROM [dbo].[fraud_detection_dataset raw]
    WHERE transaction_volume IS NOT NULL
)
WHERE transaction_volume IS NULL;

-- Impute missing values for accuracy_rate
update [dbo].[fraud_detection_dataset raw]
set transaction_volume =(
    SELECT AVG(accuracy_rate)
    FROM [dbo].[fraud_detection_dataset raw]
    WHERE accuracy_rate IS NOT NULL
)
WHERE accuracy_rate IS NULL;

-- Impute missing values for false_positive_rate 
update [dbo].[fraud_detection_dataset raw]
set  false_positive_rate  =(
    SELECT AVG( false_positive_rate )
    FROM [dbo].[fraud_detection_dataset raw]
    WHERE  false_positive_rate  IS NOT NULL
)
WHERE  false_positive_rate  IS NULL;

-- Impute missing values for customer_location
UPDATE [dbo].[fraud_detection_dataset raw]
SET customer_location = (
    SELECT TOP 1 customer_location
    FROM [dbo].[fraud_detection_dataset raw]
    GROUP BY customer_location
	 ORDER BY COUNT(*) DESC
    
)
WHERE customer_location IS NULL;

-- Impute missing values for fraud_flag
UPDATE [dbo].[fraud_detection_dataset raw]
SET fraud_flag = (
    SELECT TOP 1 fraud_flag
    FROM [dbo].[fraud_detection_dataset raw]
    GROUP BY fraud_flag
	 ORDER BY COUNT(*) DESC
    
)
WHERE fraud_flag IS NULL;

-- Identify and remove outliers in fraud_loss_amount
WITH fraud_loss_amount_stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY fraud_loss_amount) OVER () AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY fraud_loss_amount) OVER () AS q3
    FROM [dbo].[fraud_detection_dataset raw]
),
outlier_bounds_fraud AS (
    SELECT DISTINCT
        q1,
        q3,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM fraud_loss_amount_stats
)
DELETE FROM [dbo].[fraud_detection_dataset raw]
WHERE fraud_loss_amount < (SELECT lower_bound FROM outlier_bounds_fraud)
   OR fraud_loss_amount > (SELECT upper_bound FROM outlier_bounds_fraud);


   update [dbo].[fraud_detection_dataset raw]
   set transaction_type = 'other' 
   where transaction_type is null
     
  update [dbo].[fraud_detection_dataset raw]
   set merchant_category = 'other' 
   where merchant_category is null
    
	update [dbo].[fraud_detection_dataset raw]
	set accuracy_rate = coalesce(accuracy_rate, (select avg(accuracy_rate) from [dbo].[fraud_detection_dataset raw] where accuracy_rate is not null))

