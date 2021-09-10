import com.epam.edp.stages.impl.ci.ProjectType
import com.epam.edp.stages.impl.ci.Stage

@Stage(name = "liquibase-citus", buildTool = "any", type = [ProjectType.APPLICATION, ProjectType.LIBRARY])
class LiquibaseCitus {
    Script script

    void run(context) {

        script.dir("${context.workDir}") {

            context.extGetTheLatestVer = [:]
            context.extGetTheLatestVer = script.sh(returnStdout: true, script: "curl -v 'http://nexus:8081/service/rest/v1/search/assets/download?sort=version&repository=edp-maven-snapshots&maven.groupId=org.liquibase.ext&maven.artifactId=liquibase-ddm-ext&maven.extension=jar' 2>&1 | grep liquibase-ddm-ext- | cut -c 13-")
            context.extGetTheLatestVer = context.extGetTheLatestVer.replaceAll('\r', '')

            script.withCredentials([script.usernamePassword(credentialsId: 'ci.user', passwordVariable: 'passwd', usernameVariable: 'user')]) {
                script.sh """
            mkdir lib
            curl -fsSL -o lib/liquibase-ddm-ext.jar ${context.extGetTheLatestVer}
            curl -fsSL -o liquibase.jar https://github.com/liquibase/liquibase/releases/download/v4.2.1/liquibase-4.2.1.jar
            curl -fsSL -o lib/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.16.jar
            
            ls -l
            ls -l lib
            """
            }
            def citusPassword = new String(context.platform.getJsonPathValue("secret", "data-int-dev-citus-secret", ".data.password").decodeBase64())
            def citusNamespace = "mdtu-ddm-edp-cicd-data-int-dev"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar:lib/liquibase-ddm-ext.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changeLogs-preDeploy/extensions.xml \
                      --url=jdbc:postgresql://citus-master.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,pub' \
                      update"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar:lib/liquibase-ddm-ext.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changeLogs-preDeploy/extensions.xml \
                      --url=jdbc:postgresql://citus-master-rep.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,sub' \
                      update \
                      -Dconn.host=citus-master.${citusNamespace}.svc -Dconn.dbname=registry -Dconn.port=5432"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar:lib/liquibase-ddm-ext.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changelog-master-pre-deploy.xml \
                      --url=jdbc:postgresql://citus-master.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,pub' \
                      update"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar:lib/liquibase-ddm-ext.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changelog-master-pre-deploy.xml \
                      --url=jdbc:postgresql://citus-master-rep.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,sub' \
                      update \
                      -Dconn.host=citus-master.${citusNamespace}.svc -Dconn.dbname=registry -Dconn.port=5432"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar:lib/liquibase-ddm-ext.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changelog-master.xml \
                      --url=jdbc:postgresql://citus-master.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,pub' \
                      update"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar:lib/liquibase-ddm-ext.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changelog-master.xml \
                      --url=jdbc:postgresql://citus-master-rep.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,sub' \
                      update"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changelog-master-post-deploy.xml \
                      --url=jdbc:postgresql://citus-master.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,pub' \
                      update"

            script.sh "java -jar liquibase.jar \
                      --classpath=lib/postgresql.jar \
                      --driver=org.postgresql.Driver \
                      --changeLogFile=changelog-master-post-deploy.xml \
                      --url=jdbc:postgresql://citus-master-rep.${citusNamespace}.svc:5432/registry \
                      --username=postgres \
                      --password=${citusPassword} \
                      --contexts='all,sub' \
                      update \
                      -Dpwd.admin=admin -Dpwd.citizen=citizen -Dpwd.officer=officer"

        }
    }
}
return LiquibaseCitus