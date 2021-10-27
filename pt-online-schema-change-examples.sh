
sudo pt-online-schema-change --alter='engine=innodb' \
--max-load Threads_running:50,Threads_connected:300 \
--critical-load Threads_running:250,Threads_connected:400 \
--set-vars lock_wait_timeout=3 --tries create_triggers:5:5,drop_triggers:5:5 \
--no-check-replication-filters --recursion-method dsn=t=percona.dsns \
--execute --statistics --print --ask-pass D=logs,t=bll_arg,u=&lt;use&gt;


pt-online-schema-change u=root,p=pass,D=db1,t=production.customer_blink --alter=“add name varchar(20)” --statistics --execute