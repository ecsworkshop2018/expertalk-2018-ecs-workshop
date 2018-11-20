#!groovy

import jenkins.model.*

def inst = Jenkins.getInstance()

def desc = inst.getDescriptor("hudson.plugins.git.GitSCM")

desc.setGlobalConfigName("GITHUB_USER_NAME")
desc.setGlobalConfigEmail("GITHUB_USER_EMAIL")

desc.save()

"git config --global user.name GITHUB_USER_NAME".execute()
"git config --global user.email GITHUB_USER_EMAIL".execute()