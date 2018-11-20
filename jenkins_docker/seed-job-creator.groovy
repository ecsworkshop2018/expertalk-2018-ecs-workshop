pipelineJob('seed-job') {
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
}