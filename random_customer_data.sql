DROP PROCEDURE IF EXISTS production.random_customer_data;

DELIMITER |

CREATE PROCEDURE production.random_customer_data ()
SQL SECURITY INVOKER
NOT DETERMINISTIC 
MODIFIES SQL DATA 

BEGIN 
-- sample usage: 
-- CALL production.random_customer_data ()
INSERT INTO production.customer(customer_uuid)
SELECT 
    uuid()
FROM 
    -- this is just a cheesy way to do a cartesian product - yes on purpose 
    -- creates 16384 rows of imaginary customers 
	region a join
    region b join 
    region c join 
    region d join 
    region e join 
    region f join 
    region g 
;

END;

|
DELIMITER ; 