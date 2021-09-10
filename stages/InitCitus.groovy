import com.epam.edp.stages.impl.ci.ProjectType
import com.epam.edp.stages.impl.ci.Stage

@Stage(name = "init-citus", buildTool = "any", type = [ProjectType.APPLICATION, ProjectType.LIBRARY])
class InitCitus {
    Script script

    void run(context) {
        def certifiedLabsCheckoutDir = "/tmp/certified-laboratories"
        script.sh "rm -rf ${certifiedLabsCheckoutDir}"
        script.dir("${certifiedLabsCheckoutDir}") {
            script.checkout([$class                    : 'GitSCM', branches: [[name: "master"]],
                      doGenerateSubmoduleConfigurations: false, extensions: [],
                      submoduleCfg                     : [],
                      userRemoteConfigs                : [[credentialsId: "gerrit-ciuser-sshkey",
                                                           url          : "ssh://jenkins@gerrit.mdtu-ddm-edp-cicd.svc:32114/mdtu-ddm/registry-regulations/certified-laboratories-registry-regulation"]]])
        }
        
        script.dir("${context.workDir}") {
            script.sh """
            oc -n mdtu-ddm-edp-cicd-data-int-dev rsync ${certifiedLabsCheckoutDir}/data-model/data-load ${context.cituspod.master}:/tmp
            /bin/bash scripts/citusInit.sh ${context.cituspod.master} ${context.cituspod.replica} registry
            """
        }
    }
}
return InitCitus