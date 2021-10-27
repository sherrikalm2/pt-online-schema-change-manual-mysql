

# create the tables
echo "creating tables"
mysql -h $HOST -u $USER -p$PASSWORD < create_sample_tables.sql

# add the stored procedures that fill up tables with random sample data
mysql -h $HOST -u $USER -p$PASSWORD < production.random_customer_data.sql
mysql -h $HOST -u $USER -p$PASSWORD < production.random_customer_blink_data.sql 

# fill customer table with random data 
mysql -h $HOST -u $USER -p$PASSWORD --execute="CALL production.random_customer_data (); "

# fill customer_blink table with random data
mysql -h $HOST -u $USER -p$PASSWORD --execute="CALL production.random_customer_blink_data (10000); "
