#!groovy

import javaposse.jobdsl.dsl.DslScriptLoader
import javaposse.jobdsl.plugin.JenkinsJobManagement

def jobDslScript = '''pipelineJob('seed-job') {
    triggers {
        githubPush()
    }
    definition {
        cpsScm {
            scm {
                git('SEED_JOB_REPO_URL', "master")
            }
            scriptPath('Jenkinsfile')
        }
    }
}'''

def workspace = new File('.')

def jobManagement = new JenkinsJobManagement(System.out, [:], workspace)

new DslScriptLoader(jobManagement).runScript(jobDslScript)