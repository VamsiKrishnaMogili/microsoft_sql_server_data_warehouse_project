-- Insert processed data into the target table 'stagecache.erp_cust_az12'
INSERT INTO stagecache.erp_cust_az12 (cid, bdate, gen)
SELECT
    -- Clean and extract 'cid' by trimming spaces and taking substring 
    -- starting one character before 'W' up to the full string length.
    TRIM(SUBSTRING(cid, CHARINDEX('W', cid) - 1, LEN(cid))) AS cid,
    
    -- Replace future birthdates with NULL, otherwise keep original date.
    CASE 
        WHEN bdate >= GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    
    -- Standardize gender values:
    -- Convert 'M' or 'MALE' (case insensitive) to 'Male'
    -- Convert 'F' or 'FEMALE' to 'Female'
    -- If not matching any, assign 'n/a'
    CASE
        WHEN UPPER(gen) = 'M' OR UPPER(gen) = 'MALE' THEN 'Male'
        WHEN UPPER(gen) = 'F' OR UPPER(gen) = 'FEMALE' THEN 'Female'
        ELSE 'n/a'
    END AS gen
FROM staging.erp_cust_az12;  -- Source table for staging data
