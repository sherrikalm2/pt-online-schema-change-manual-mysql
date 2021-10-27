-- ------------------------------------------------------------------------
-- Create sample production schema and tables 
-- ------------------------------------------------------------------------

-- ------------------------------------------
-- Create schema 
-- ------------------------------------------
-- for demostration purposes only, please don't name a schema production in real life 
-- this represents the schema where the prodution table currently resides
CREATE SCHEMA IF NOT EXISTS production; 

-- this is the schema where the work is being done
CREATE SCHEMA IF NOT EXISTS schema_change; -- 'Manual schema change tables reside here while work is in progress.'

-- this is where the old table will reside once the swip swap rename event is complete 
CREATE SCHEMA IF NOT EXISTS control_z; -- because undo is a key word 

USE production; 

-- ------------------------------------------
-- production.region
-- lookup table for foreign key demostrations  
-- ------------------------------------------
DROP TABLE IF EXISTS production.region; 
CREATE TABLE production.region(
region_id INTEGER NOT NULL AUTO_INCREMENT COMMENT 'Surrogate auto incrementing key.',
region_name VARCHAR(50) NOT NULL COMMENT 'Required. Must be unique. The name of the region. ',
PRIMARY KEY(region_id), 
UNIQUE(region_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
COMMENT 'A sample lo-fi lookup table for demonstration purposes. Real life lookup tables should have auditing, but that is not the focus of this discussion.' 
;

ALTER TABLE production.region CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci ;

INSERT INTO production.region (region_name)
VALUES 
('North'),
('South'),
('East'),
('West')
;

-- ------------------------------------------
-- production.customer
-- medium size table for foreign key demostrations  
-- ------------------------------------------
DROP TABLE IF EXISTS production.customer; 
CREATE TABLE production.customer(
customer_id INTEGER NOT NULL AUTO_INCREMENT,
customer_uuid VARCHAR(50) NOT NULL COMMENT 'Required. Must be unique. The uuid of the customer. ',
PRIMARY KEY (customer_id),
UNIQUE(customer_uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
COMMENT 'A sample lo-fi customer table for foreign key demonstration purposes only. ' 
;
ALTER TABLE production.region CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci ;

-- ------------------------------------------
-- production.customer_blink
-- large size table to demonstrate how to roll your own pt-online-schema-change 
-- ------------------------------------------
DROP TABLE IF EXISTS production.customer_blink; 
CREATE TABLE production.customer_blink(
customer_blink_id INTEGER NOT NULL AUTO_INCREMENT COMMENT 'Surrogate key. Primary key. Not null auto incrementing.',
customer_id INTEGER NOT NULL COMMENT 'Foreign key to production.customer.customer_id.',
region_id INTEGER NOT NULL COMMENT 'Foreign key to production.region.region_id', 
blink_count INTEGER NOT NULL DEFAULT 1 COMMENT 'How many times did you blink.', 
date_inserted DATETIME NOT NULL DEFAULT NOW() COMMENT 'Defaults to ',
PRIMARY KEY(customer_blink_id) ,
CONSTRAINT FOREIGN KEY fk_customer_blink_customer_id (customer_id) REFERENCES production.customer(customer_id), 
CONSTRAINT FOREIGN KEY fk_customer_blink_region_id (region_id) REFERENCES production.region(region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
COMMENT 'Silly and for demonstration purposes only. 
Lets count the number of times a customer blinks. 
Which, btw,  is about 14,400 - 19,200 times a day for the average person. ' 
;

ALTER TABLE production.customer_blink CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci ;

-- ------------------------------------------
-- Now for our changed table 
--  lets change the integer id to a big int 
--  and add a column for the insert user 
--
-- schema_change.customer_blink_target
-- ------------------------------------------
DROP TABLE IF EXISTS schema_change.customer_blink_target;
CREATE TABLE schema_change.customer_blink_target(
customer_blink_id BIGINT NOT NULL AUTO_INCREMENT COMMENT 'Surrogate key. Primary key. Not null auto incrementing.',
customer_id INTEGER NOT NULL COMMENT 'Foreign key to production.customer.customer_id.',
region_id INTEGER NOT NULL COMMENT 'Foreign key to production.region.region_id', 
blink_count INTEGER NOT NULL DEFAULT 1 COMMENT 'How many times did you blink.', 
inserted_by VARCHAR(50) NOT NULL DEFAULT 'UNKNOWN' COMMENT 'What user inserted the row.',
date_inserted DATETIME NOT NULL DEFAULT NOW() COMMENT 'Defaults to ',
PRIMARY KEY(customer_blink_id) ,
CONSTRAINT FOREIGN KEY fk_customer_blink_customer_id (customer_id) REFERENCES production.customer(customer_id), 
CONSTRAINT FOREIGN KEY fk_customer_blink_region_id (region_id) REFERENCES production.region(region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci 
COMMENT 'Silly and for demonstration purposes only. 
Lets count the number of times a customer blinks. 
Which, btw,  is about 14,400 - 19,200 times a day for the average person. ' 
;
ALTER TABLE production.customer_blink CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci ;


