#!groovy

import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.CredentialsScope
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import hudson.util.Secret
import org.jenkinsci.plugins.github.config.GitHubPluginConfig
import org.jenkinsci.plugins.github.config.GitHubServerConfig

def instance = Jenkins.getInstance()

def secretId = "github-access-token"

def secretText = new StringCredentialsImpl(
        CredentialsScope.GLOBAL,
        secretId,
        "Github access token",
        Secret.fromString("GITHUB_ACCESS_TOKEN")
)

def usernameAndPassword = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL,
        "github-user-name-plus-api-token",
        "Github access credentials",
        "GITHUB_USER_NAME",
        "GITHUB_ACCESS_TOKEN"
)

SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), secretText)
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), usernameAndPassword)

def github = jenkins.model.Jenkins.instance.getExtensionList(GitHubPluginConfig.class)[0]

def githubServerConfig = new GitHubServerConfig(secretId)
githubServerConfig.setName("GitHub")
github.setConfigs([githubServerConfig])
github.save()

instance.save()