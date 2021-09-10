import com.epam.edp.stages.impl.ci.ProjectType
import com.epam.edp.stages.impl.ci.Stage

@Stage(name = "get-version", buildTool = ["any", "helm", "docker", "docker-external", "other"], type = [ProjectType.APPLICATION, ProjectType.LIBRARY])
class GetVersionAnyApplicationLibrary {
    Script script

    def setVersionToArtifact(context) {
        script.sh """
             kubectl patch codebasebranches.v2.edp.epam.com ${context.codebase.config.name}-${context.git.branch.replaceAll(/\//, "-")} --type=merge -p '{\"status\": {\"build\": "${context.codebase.currentBuildNumber}"}}'
        """
    }

    void run(context) {
        setVersionToArtifact(context)
        context.codebase.vcsTag = "build/${context.codebase.version}"
        context.codebase.isTag = "${context.codebase.version}"
        context.codebase.deployableModuleDir = "${context.workDir}"

        script.println("[JENKINS][DEBUG] Artifact version - ${context.codebase.version}")
        script.println("[JENKINS][DEBUG] VCS tag - ${context.codebase.vcsTag}")
        script.println("[JENKINS][DEBUG] IS tag - ${context.codebase.isTag}")
    }
}
return GetVersionAnyApplicationLibrary