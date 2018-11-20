pipelineJob('seed-job') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('SEED_JOB_REPO_URL')
                    }
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}