import com.epam.edp.stages.impl.ci.ProjectType
import com.epam.edp.stages.impl.ci.Stage

@Stage(name = "clean-citus", buildTool = "any", type = [ProjectType.APPLICATION, ProjectType.LIBRARY])
class CleanupCitus {
    Script script

    void run(context) {
        script.dir("${context.workDir}") {

            context.cituspod = [:]
            context.cituspod.master = script.sh(returnStdout: true, script: "oc -n mdtu-ddm-edp-cicd-data-int-dev get pod -l app=citus-master -o jsonpath=\"{.items[0].metadata.name}\"")
            context.cituspod.replica = script.sh(returnStdout: true, script: "oc -n mdtu-ddm-edp-cicd-data-int-dev get pod -l app=citus-master-rep -o jsonpath=\"{.items[0].metadata.name}\"")

            script.sh "/bin/bash scripts/citusDrop.sh ${context.cituspod.master} ${context.cituspod.replica} registry"
        }
    }
}
return CleanupCitus