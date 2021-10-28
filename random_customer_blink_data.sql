DROP PROCEDURE IF EXISTS production.random_customer_blink_data;

DELIMITER |

CREATE PROCEDURE production.random_customer_blink_data ()
SQL SECURITY INVOKER
NOT DETERMINISTIC 
MODIFIES SQL DATA 

BEGIN 
-- select FLOOR( RAND() * (maximumValue-minimumValue) + minimumValue) as anyVariableName;
-- sample usage: 
-- CALL production.random_customer_blink_data ()
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
FROM 
    -- this is just a cheesy way to do a cartesian product - yes on purpose 
    -- creates 65,536 rows of imaginary customer_blink events 
    -- can run this over sproc over and over again if you want more data 
	customer a join
    region b 
    ;

END;

|
DELIMITER ; 