#!/bin/bsh

master_pod=$1
replica_pod=$2
db=$3

kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $replica_pod -- psql $db -U postgres -c "SELECT run_command_on_workers('ALTER SUBSCRIPTION operational_sub disable; ALTER SUBSCRIPTION operational_sub SET (slot_name = NONE); DROP SUBSCRIPTION operational_sub;');"
kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $replica_pod -- psql $db -U postgres -c "ALTER SUBSCRIPTION operational_sub disable; ALTER SUBSCRIPTION operational_sub SET (slot_name = NONE); DROP SUBSCRIPTION operational_sub;"

kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $master_pod -- psql postgres -U postgres -c "SELECT run_command_on_workers('SELECT pg_drop_replication_slot(''operational_sub'');');"
kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $master_pod -- psql postgres -U postgres -c "SELECT pg_drop_replication_slot('operational_sub');"

kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $replica_pod -- psql postgres -U postgres -c "SELECT run_command_on_workers('SELECT COUNT(pg_terminate_backend(pg_stat_activity.pid)) FROM pg_stat_activity WHERE datname = ''$db'' AND pid <> pg_backend_pid()');"
kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $replica_pod -- psql postgres -U postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = '$db' AND pid <> pg_backend_pid();"

kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $master_pod -- psql postgres -U postgres -c "SELECT run_command_on_workers('SELECT COUNT(pg_terminate_backend(pg_stat_activity.pid)) FROM pg_stat_activity WHERE datname = ''$db'' AND pid <> pg_backend_pid()');"
kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $master_pod -- psql postgres -U postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = '$db' AND pid <> pg_backend_pid();"

kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $replica_pod -- psql postgres -U postgres -c "DROP DATABASE $db;"
kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $replica_pod -- psql postgres -U postgres -c "SELECT run_command_on_workers('DROP DATABASE $db;');"

kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $master_pod -- psql postgres -U postgres -c "DROP DATABASE $db;"
kubectl exec -n mdtu-ddm-edp-cicd-data-int-dev $master_pod -- psql postgres -U postgres -c "SELECT run_command_on_workers('DROP DATABASE $db;');"
