#!groovy

import jenkins.model.JenkinsLocationConfiguration

jlc = JenkinsLocationConfiguration.get()
jlc.setUrl("ROOT_URL")
jlc.save()