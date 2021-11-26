# data-model

### Overview
Contains two changeLog repositories to init registry DB:
1. changeLogs-preDeploy (changelog-master-pre-deploy.xml):
   - is not available to registry administrator
   - contains domains and version control
   - static and the same for all registries
   - uses standard functionality of Liquibase
   - is used before registry objects deployment
2. changeLogs-postDeploy (changelog-master-post-deploy.xml):
   - is not available to registry administrator
   - contains actions that must be executed the last
   - static and the same for all registries
   - uses standard functionality of Liquibase
   - is used after registry objects deployment

### Usage
To deploy registry DB follow next steps:
1. Execute preDeploy script:
```bash
lb_params="--logLevel=info --databaseChangeLogTableName=ddm_db_changelog --databaseChangeLogLockTableName=ddm_db_changelog_lock --classpath=postgresql-42.2.23.jar --liquibaseSchemaName=public --driver=org.postgresql.Driver"
java -jar liquibase.jar --contexts="all,pub" $lb_params --changeLogFile=changelog-master-pre-deploy.xml --username=<username> --password=<password> --url=jdbc:postgresql://<master_DB_instance>:5432/<dbname> --labels=!citus update
java -jar liquibase.jar --contexts="all,sub" $lb_params --changeLogFile=changelog-master-pre-deploy.xml --username=<username> --password=<password> --url=jdbc:postgresql://<replica_DB_instance>:5432/<dbname> --labels=!citus update
```
2. Deploy objects from desired registry.
3. Execute postDeploy script.
```bash
lb_params="--logLevel=info --databaseChangeLogTableName=ddm_db_changelog --databaseChangeLogLockTableName=ddm_db_changelog_lock --classpath=postgresql-42.2.23.jar --liquibaseSchemaName=public --driver=org.postgresql.Driver"
java -jar liquibase.jar --contexts="all,pub" $lb_params --changeLogFile=changelog-master-post-deploy.xml --username=<username> --password=<password> --url=jdbc:postgresql://<master_DB_instance>:5432/<dbname> --labels=!citus update
java -jar liquibase.jar --contexts="all,sub" $lb_params --changeLogFile=changelog-master-post-deploy.xml --username=<username> --password=<password> --url=jdbc:postgresql://<replica_DB_instance>:5432/<dbname> --labels=!citus update
```

### Local development

###### Prerequisites
* Postgres databases (master DB and replica DB) with citus extension are configured and running
* Liquibase is installed
* Postgres JDBC driver is downloaded

###### Steps
Run Liquibase commands mentioned above.

### Licensing
The data-model is Open Source software released under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0).