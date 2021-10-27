
-- ----------------------------------------------------- 
-- INSERT TRIGGER 
-- ----------------------------------------------------- 
DROP TRIGGER IF EXISTS tr_production_customer_blink_insert_a;

DELIMITER | 

CREATE 
TRIGGER tr_production_customer_blink_insert_a
AFTER INSERT ON production.customer_blink

FOR EACH ROW  

BEGIN 

REPLACE INTO schema_change.customer_blink_target
(customer_blink_id ,
customer_id, 
region_id ,
blink_count, 
date_inserted
)
VALUES (
NEW.customer_blink_id, 
NEW.customer_id, 
NEW.region_id, 
NEW.blink_count, 
NEW.date_inserted 
) 
;

END; 
| 
DELIMITER ; 


-- ----------------------------------------------------- 
-- UPDATE TRIGGER 
-- ----------------------------------------------------- 
DROP TRIGGER IF EXISTS tr_production_customer_blink_update_a;

DELIMITER | 

CREATE 
TRIGGER tr_production_customer_blink_update_a
AFTER UPDATE ON production.customer_blink

FOR EACH ROW  

BEGIN 

REPLACE INTO schema_change.customer_blink_target
(
customer_blink_id,
customer_id, 
region_id, 
blink_count,
date_inserted)
VALUES (
NEW.customer_blink_id,
NEW.customer_id, 
NEW.region_id,
NEW.blink_count, 
NEW.date_inserted
)
;

END; 
| 
DELIMITER ; 

-- ----------------------------------------------------- 
-- DELETE TRIGGER  - ok I don't condone hard deletes, but if you really must.. 
-- ----------------------------------------------------- 
DROP TRIGGER IF EXISTS tr_production_customer_blink_delete_a;

DELIMITER | 

CREATE 
TRIGGER tr_production_customer_blink_delete_a
AFTER DELETE ON production.customer_blink

FOR EACH ROW  

BEGIN 

DELETE IGNORE FROM schema_change.customer_blink_target 
WHERE 
    customer_blink_id <=> OLD.customer_blink_id ;

END; 
| 
DELIMITER ; 





