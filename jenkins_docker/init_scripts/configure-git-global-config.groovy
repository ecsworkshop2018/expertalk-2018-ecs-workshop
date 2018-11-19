#!groovy

import jenkins.model.*

def inst = Jenkins.getInstance()

def desc = inst.getDescriptor("hudson.plugins.git.GitSCM")

desc.setGlobalConfigName("FIRST_NAME-jenkins")
desc.setGlobalConfigEmail("FIRST_NAME-jenkins@ecsworkshop2018.online")

desc.save()

"git config --global user.name FIRST_NAME-jenkins".execute()
"git config --global user.email FIRST_NAME-jenkins@ecsworkshop2018.online".execute()