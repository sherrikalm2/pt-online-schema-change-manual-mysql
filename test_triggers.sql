-- manual tests

-- ---------------------------------------------------
-- simulate adding a row 
-- ---------------------------------------------------

INSERT INTO production.customer_blink(
customer_id ,
region_id ,
blink_count ,
date_inserted )

SELECT 
    FLOOR( RAND() * (16384-1) + 1) as customer_id,
    FLOOR( RAND() * (4-1) + 1) as region_id,
    FLOOR( RAND() * (19200-14000) + 14000) as blink_count,
    CURRENT_TIMESTAMP - INTERVAL FLOOR(RAND() * 365 * 24 * 60 *60) SECOND as date_inserted
;

SET @customer_blink_id := LAST_INSERT_ID(); 

SELECT 
    'src', 
    customer_blink_id, 
    customer_id, 
    region_id ,
    blink_count, 
    date_inserted
FROM 
    production.customer_blink 
WHERE 
    customer_blink_id = @customer_blink_id 
UNION 
SELECT 
    'target', 
    customer_blink_id, 
    customer_id, 
    region_id ,
    blink_count, 
    date_inserted
FROM 
    schema_change.customer_blink_target
WHERE 
    customer_blink_id = @customer_blink_id 
;

-- expected behaviour 
-- 1 row added to production.customer_blink 
-- 1 row added to schema_change.customer_blink_target 

-- ---------------------------------------------------
-- simulate updating a row 
-- ---------------------------------------------------
UPDATE production.customer_blink
SET 
customer_id = 1, 
region_id = 3
WHERE customer_blink_id = @customer_blink_id
;

SELECT 
    'src', 
    customer_blink_id, 
    customer_id, 
    region_id ,
    blink_count, 
    date_inserted
FROM 
    production.customer_blink 
WHERE 
    customer_blink_id = @customer_blink_id 
UNION 
SELECT 
    'target', 
    customer_blink_id, 
    customer_id, 
    region_id ,
    blink_count, 
    date_inserted
FROM 
    schema_change.customer_blink_target
WHERE 
    customer_blink_id = @customer_blink_id 
;

-- expected behaviour 
-- 1 row updated in production.customer_blink 
-- same row updated in schema_change.customer_blink_target 

-- ---------------------------------------------------
-- simulate deleting a row 
-- ---------------------------------------------------

DELETE FROM production.customer_blink WHERE customer_blink_id = @customer_blink_id ; 

SELECT 
    'src', 
    customer_blink_id, 
    customer_id, 
    region_id ,
    blink_count, 
    date_inserted
FROM 
    production.customer_blink 
WHERE 
    customer_blink_id = @customer_blink_id 
UNION 
SELECT 
    'target', 
    customer_blink_id, 
    customer_id, 
    region_id ,
    blink_count, 
    date_inserted
FROM 
    schema_change.customer_blink_target
WHERE 
    customer_blink_id = @customer_blink_id 
;

-- expected behaviour 
-- 1 row deleted from production.customer_blink 
-- same row deleted from schema_change.customer_blink_target 
-- query test should return empty set 


