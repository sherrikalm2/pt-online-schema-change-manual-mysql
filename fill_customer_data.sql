
DROP PROCEDURE IF EXISTS schema_change.fill_customer_data;

DELIMITER |

CREATE PROCEDURE schema_change.fill_customer_data (
v_start INTEGER,
v_stop INTEGER, 
v_rows INTEGER
)
SQL SECURITY INVOKER
NOT DETERMINISTIC 
MODIFIES SQL DATA 

BEGIN 

-- ---------------------------------------------------------------------------------
-- 
-- loop over all the target_table_name rows and stuff them in the staging table 
-- may want to throttle this to only run during daylight supervised times
-- don't have to do the whole thing at once 
-- keep track and use  v_stop to pass in sizes less than the whole table 
--
-- v_start is the id to start on
-- v_stop is the id to end on 
-- v_sleep is the number of seconds to wait between ba
--
-- SAMPLE Usage: back fill the first 1000 
-- CALL schema_change.fill_customer_data( 1, 1000, 10000, 0.5);
-- 

DECLARE v_source_id BIGINT DEFAULT v_start;

-- for monitoring in flight 
CREATE IF NOT EXISTS TABLE schema_change.customer_blink_log (i BIGINT, logtime DATETIME(6) NOT NULL DEFAULT NOW(6),  
KEY(i), KEY(logtime)
);

-- to watch while it is running 
-- select * from schema_change.customer_blink_log order by logtime desc;

-- ---------------------------
-- Loop over each id 
-- this is not the most efficient way but is less likely to cause contention in a very busy table 
-- ---------------------------

	WHILE v_source_id < v_stop DO
    
	BEGIN
		
		START TRANSACTION; 
		-- ---------------------------
		-- Log where we are 
		-- ---------------------------

		INSERT INTO schema_change.customer_blink_log  (i) VALUES (v_source_id); 
        
        -- ---------------------------
        -- fill up the staging table 
        -- ---------------------------
        -- Use Ignore here because we do NOT want to upsert 
        -- in the event that any updates are made before the backfill we would want to keep those updates
        
        INSERT LOW_PRIORITY IGNORE 
        INTO schema_change.customer_blink_target 
        (
        customer_blink_id,
        customer_id,
        region_id,
        blink_count,
        inserted_by ,
        date_inserted 
        )

        SELECT 
            customer_blink_id,
            customer_id,
            region_id,
            blink_count,
            'UNKNOWN' as inserted_by ,
            date_inserted 
        FROM 
            production.customer_blink
        WHERE 
            customer_blink_id = v_source_id 
        LOCK IN SHARE MODE
        ;
        
        COMMIT; -- ends the transaction

        SELECT SLEEP(v_sleep);
			
	END;

		SET v_source_id = v_source_id + 1; 
    
	END WHILE;

END;

|