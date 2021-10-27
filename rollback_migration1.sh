# rollback_migration1.sh
echo "rollback_migration1.sql"
mysql -h $HOST -u $USER -p$PASSWORD < rollback_migration1.sql
