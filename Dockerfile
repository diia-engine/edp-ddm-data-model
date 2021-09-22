FROM nexus-docker-registry.apps.cicd2.mdtu-ddm.projects.epam.com/liquibase/liquibase

USER root
RUN apt-get update -y && apt-get install curl -y && rm -rf /var/lib/apt/lists/*
USER liquibase
RUN curl -fsSL -o /liquibase/lib/liquibase-ddm-ext.jar https://nexus-public-mdtu-ddm-edp-cicd.apps.cicd2.mdtu-ddm.projects.epam.com/repository/edp-maven-snapshots/com/epam/digital/data/platform/liquibase-ddm-ext/1.4.0-SNAPSHOT/liquibase-ddm-ext-1.4.0-20210921.125505-16.jar
COPY changelog-master-post-deploy.xml changelog-master-pre-deploy.xml /liquibase
COPY xsd /liquibase/xsd
COPY changeLogs-postDeploy /liquibase/changeLogs-postDeploy
COPY changeLogs-preDeploy /liquibase/changeLogs-preDeploy
