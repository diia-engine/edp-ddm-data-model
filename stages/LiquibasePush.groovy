import com.epam.edp.stages.impl.ci.ProjectType
import com.epam.edp.stages.impl.ci.Stage

@Stage(name = "liquibase-push", buildTool = "any", type = [ProjectType.APPLICATION, ProjectType.LIBRARY])
class LiquibasePush {
    Script script

    void run(context) {
        script.dir("${context.workDir}") {

            script.sh """
              mkdir liquibase-repositories
              cp -r changeLogs-preDeploy liquibase-repositories/changeLogs-preDeploy
              cp changelog-master-pre-deploy.xml liquibase-repositories/changelog-master-pre-deploy.xml
              cp -r changeLogs-postDeploy liquibase-repositories/changeLogs-postDeploy
              cp changelog-master-post-deploy.xml liquibase-repositories/changelog-master-post-deploy.xml
              tar -zcvf liquibaserepo-${context.codebase.version}.tar.gz liquibase-repositories
              """

            def rawRepoVersion = context.codebase.version.split('-')

            if (context.codebase.version.contains("SNAPSHOT")) {
                def repoVersion = rawRepoVersion[0]+'-SNAPSHOT'
                script.nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: "${context.nexus.host}:${context.nexus.port}",
                        groupId: 'com.epam.digital.data.platform',
                        version: repoVersion,
                        repository: 'edp-maven-snapshots',
                        credentialsId: 'ci.user',
                        artifacts: [
                                [artifactId: "liquibaserepo",
                                 classifier: '',
                                 file      : "liquibaserepo-${context.codebase.version}.tar.gz",
                                 type      : 'tar.gz']
                        ]
                )
            }
            if (context.codebase.version.contains("RC")) {
                def repoVersion = rawRepoVersion[0]
                script.nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: "${context.nexus.host}:${context.nexus.port}",
                        groupId: 'com.epam.digital.data.platform',
                        version: repoVersion,
                        repository: 'edp-maven-releases',
                        credentialsId: 'ci.user',
                        artifacts: [
                                [artifactId: "liquibaserepo",
                                 classifier: '',
                                 file      : "liquibaserepo-${context.codebase.version}.tar.gz",
                                 type      : 'tar.gz']
                        ]
                )
            }
        }
    }
}
return LiquibasePush