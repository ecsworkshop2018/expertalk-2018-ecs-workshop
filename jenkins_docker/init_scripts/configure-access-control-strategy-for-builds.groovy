#!groovy

import jenkins.model.Jenkins
import jenkins.security.QueueItemAuthenticatorConfiguration
import org.jenkinsci.plugins.authorizeproject.GlobalQueueItemAuthenticator
import org.jenkinsci.plugins.authorizeproject.strategy.SpecificUsersAuthorizationStrategy

def instance = Jenkins.getInstance()

GlobalQueueItemAuthenticator auth = new GlobalQueueItemAuthenticator(new SpecificUsersAuthorizationStrategy("JENKINS_USER_NAME"));
QueueItemAuthenticatorConfiguration.get().getAuthenticators().add(auth);

instance.save()