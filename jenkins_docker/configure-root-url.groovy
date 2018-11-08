#!groovy

import jenkins.model.JenkinsLocationConfiguration

rootUrl = "http://localhost:8080/"

jlc = JenkinsLocationConfiguration.get()
jlc.setUrl(rootUrl)
jlc.save()