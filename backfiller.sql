DROP PROCEDURE IF EXISTS schema_change.backfiller;

DELIMITER |

CREATE PROCEDURE schema_change.backfiller (
v_start_id INTEGER,
v_stop_id INTEGER, 
v_chunk_size INTEGER,
v_sleep FLOAT
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
-- CALL schema_change.backfiller( 1, 1000, 100, 0.1); -- for testing 
-- 
-- to get the value of v_stop - 
-- SELECT MIN(customer_blink_id) FROM schema_change.customer_blink_target
-- CALL schema_change.backfiller( 1, 1000, 100, 0.1);
-- 
-- to watch while it is running 
-- select * from schema_change.customer_blink_log order by logtime desc;

DECLARE v_chunk_start_id BIGINT DEFAULT v_start_id;
DECLARE v_chunk_end_id BIGINT DEFAULT v_chunk_start_id + (v_chunk_size -1) ;

-- ---------------------------
-- Loop over each id 
-- this is not the most efficient way but is less likely to cause contention in a very busy table 
-- ---------------------------

	WHILE v_chunk_start_id < v_stop_id DO
    
	BEGIN
		
		START TRANSACTION; 
		-- ---------------------------
		-- Log where we are 
		-- ---------------------------

		INSERT INTO schema_change.customer_blink_log  (i, chunk_start_id, chunk_end_id ) 
        VALUES (v_start_id, v_chunk_start_id, v_chunk_end_id); 

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
            customer_blink_id BETWEEN v_chunk_start_id AND v_chunk_end_id
        ;
        
        COMMIT; -- ends the transaction

        SELECT SLEEP(v_sleep);
			
	END;
        -- increment our incrementors 
		SET v_start_id = v_start_id + 1; 

        SET v_chunk_start_id = v_chunk_end_id + 1 ; 
        SET v_chunk_end_id = v_chunk_end_id + (v_chunk_size) ;
    
	END WHILE;

END;

|
DELIMITER ; 