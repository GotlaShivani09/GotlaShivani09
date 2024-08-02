select * from [dbo].[Copy of compliance_monitoring_dataset(1)]

--remove null values of primary key 
select * from [dbo].[Copy of compliance_monitoring_dataset(1)]
where regulation_id is not null
and employee_id is not null
and year is not null

-- replacing the numerical values with mean
UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Time_to_Compliance_Days = (SELECT AVG(Time_to_Compliance_Days) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Time_to_Compliance_Days IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Training_Completion_Rate = (SELECT AVG(Training_Completion_Rate) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Training_Completion_Rate IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Compliance_Breaches = (SELECT AVG(Compliance_Breaches) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Compliance_Breaches IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET  Audit_Findings = (SELECT AVG(Audit_Findings) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Audit_Findings IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Audit_Score = (SELECT AVG(Audit_Score) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Audit_Score IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Fines_Penalties_Amount = (SELECT AVG(Fines_Penalties_Amount) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Fines_Penalties_Amount IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Incident_Response_Time_Minutes = (SELECT AVG(Incident_Response_Time_Minutes) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Incident_Response_Time_Minutes IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Suspicious_Activity_Reports = (SELECT AVG(Suspicious_Activity_Reports) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Suspicious_Activity_Reports IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Regulatory_Change_Impact_Score = (SELECT AVG(Regulatory_Change_Impact_Score) FROM [dbo].[Copy of compliance_monitoring_dataset(1)])
WHERE Regulatory_Change_Impact_Score IS NULL;

--replacing categorical values 

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Location = (SELECT TOP 1 Location FROM [dbo].[Copy of compliance_monitoring_dataset(1)] GROUP BY Location ORDER BY COUNT(*) DESC )
WHERE Location IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Quarter = (SELECT TOP 1 Quarter FROM [dbo].[Copy of compliance_monitoring_dataset(1)]GROUP BY Quarter ORDER BY COUNT(*) DESC )
WHERE Quarter IS NULL;
 
 UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Compliance_Manager = (SELECT TOP 1 Compliance_Manager FROM [dbo].[Copy of compliance_monitoring_dataset(1)] GROUP BY Compliance_Manager ORDER BY COUNT(*) DESC )
WHERE Compliance_Manager IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Training_Session_Attended = 
(SELECT TOP 1 Training_Session_Attended FROM [dbo].[Copy of compliance_monitoring_dataset(1)] GROUP BY Training_Session_Attended ORDER BY COUNT(*) DESC)
WHERE Training_Session_Attended IS NULL;

UPDATE [dbo].[Copy of compliance_monitoring_dataset(1)]
SET Audit_Type = (SELECT TOP 1 Audit_Type FROM [dbo].[Copy of compliance_monitoring_dataset(1)] GROUP BY Audit_Type ORDER BY COUNT(*) DESC )
WHERE Audit_Type IS NULL;
 
 update [dbo].[Copy of compliance_monitoring_dataset(1)]
   set Department = 'other' 
   where Department is null

--remove ouliers  
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Fines_Penalties_Amount) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Fines_Penalties_Amount) OVER () AS Q3
    FROM [dbo].[Copy of compliance_monitoring_dataset(1)]
    -- Ensure this query returns a single row with the calculated percentiles
)
SELECT *
FROM [dbo].[Copy of compliance_monitoring_dataset(1)] AS dataset
CROSS JOIN (SELECT DISTINCT Q1, Q3 FROM stats) AS stats
WHERE dataset.Fines_Penalties_Amount < (stats.Q1 - 1.5 * (stats.Q3 - stats.Q1))
   OR dataset.Fines_Penalties_Amount > (stats.Q3 + 1.5 * (stats.Q3 - stats.Q1));

  --recording values 
UPDATE  [dbo].[Copy of compliance_monitoring_dataset(1)] 
SET Training_Session_Attended = CASE
    WHEN Training_Session_Attended = 'Yes' THEN '1'
    WHEN Training_Session_Attended = 'No' THEN '0'
END;

UPDATE  [dbo].[Copy of compliance_monitoring_dataset(1)] 
SET Audit_Type = CASE
    WHEN Audit_Type = 'Internal' THEN 'I'
    WHEN Audit_Type = 'External' THEN 'E'
END;

