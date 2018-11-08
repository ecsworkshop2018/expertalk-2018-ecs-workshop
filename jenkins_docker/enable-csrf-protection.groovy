#!groovy

import jenkins.model.Jenkins
import hudson.security.csrf.DefaultCrumbIssuer;

def instance = Jenkins.getInstance()

instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
instance.save()