#!/bin/bsh

master_pod=$1
replica_pod=$2
db=$3
db_audit=${db}_audit

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql -U postgres -c "CREATE DATABASE $db;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql -U postgres -c "SELECT run_command_on_workers('CREATE DATABASE $db;');"

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql -U postgres -c "CREATE DATABASE $db_audit;"
#kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- echo "SELECT 'CREATE DATABASE $db_audit' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db_audit')\gexec" | psql -U postgres

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql $db -U postgres -c "CREATE EXTENSION IF NOT EXISTS citus;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-0 -- psql $db -U postgres -c "CREATE EXTENSION IF NOT EXISTS citus;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-1 -- psql $db -U postgres -c "CREATE EXTENSION IF NOT EXISTS citus;"

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-0 -- psql $db -U postgres -c "CREATE PUBLICATION analytical_pub WITH ( publish = 'insert, update, delete, truncate');"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-1 -- psql $db -U postgres -c "CREATE PUBLICATION analytical_pub WITH ( publish = 'insert, update, delete, truncate');"

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql $db -U postgres -c "SELECT master_add_node('citus-worker-0.citus-workers', 5432),master_add_node('citus-worker-1.citus-workers', 5432);"


kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $replica_pod -- psql -U postgres -c "CREATE DATABASE $db;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $replica_pod -- psql -U postgres -c "SELECT run_command_on_workers('CREATE DATABASE $db;');"

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $replica_pod -- psql $db -U postgres -c "CREATE EXTENSION IF NOT EXISTS citus;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-rep-0 -- psql $db -U postgres -c "CREATE EXTENSION IF NOT EXISTS citus;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-rep-1 -- psql $db -U postgres -c "CREATE EXTENSION IF NOT EXISTS citus;"

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-rep-0 -- psql $db -U postgres -c "CREATE SUBSCRIPTION operational_sub CONNECTION 'dbname=$db host=citus-worker-0.citus-workers user=postgres port=5432' PUBLICATION analytical_pub;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec citus-worker-rep-1 -- psql $db -U postgres -c "CREATE SUBSCRIPTION operational_sub CONNECTION 'dbname=$db host=citus-worker-1.citus-workers user=postgres port=5432' PUBLICATION analytical_pub;"

kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $replica_pod -- psql $db -U postgres -c "SELECT master_add_node('citus-worker-rep-0.citus-workers-rep', 5432),master_add_node('citus-worker-rep-1.citus-workers-rep', 5432);"

# additional extensions init
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql postgres -U postgres -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $replica_pod -- psql postgres -U postgres -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"

# create archive schema
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql $db -U postgres -c "CREATE SCHEMA IF NOT EXISTS archive;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $master_pod -- psql $db -U postgres -c "SELECT run_command_on_workers('CREATE SCHEMA IF NOT EXISTS archive;');"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $replica_pod -- psql $db -U postgres -c "CREATE SCHEMA IF NOT EXISTS archive;"
kubectl -n mdtu-ddm-edp-cicd-data-int-dev exec $replica_pod -- psql $db -U postgres -c "SELECT run_command_on_workers('CREATE SCHEMA IF NOT EXISTS archive;');"
