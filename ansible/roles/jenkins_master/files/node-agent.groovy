#!/usr/bin/env groovy

import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import hudson.plugins.sshslaves.*;

println "--> creating SSH credentials"

domain = Domain.global()
store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

slavesPrivateKey = new com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey(
CredentialsScope.GLOBAL,
"jenkins-slaves",
"ec2-user",
new com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey.UsersPrivateKeySource(),
"",
""
)

managersPrivateKey = new com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey(
CredentialsScope.GLOBAL,
"swarm-managers",
"ec2-user",
new com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey.UsersPrivateKeySource(),
"",
""
)

// githubCredentials = new com.cloudbees.jenkins.plugins.sshcredentials.impl.UsernamePasswordCredentialsImpl(
//   CredentialsScope.GLOBAL,
//   "github", "Github credentials",
//   "USERNAME",
//   "PASSWORD"
// )

// registryCredentials = new com.cloudbees.jenkins.plugins.sshcredentials.impl.UsernamePasswordCredentialsImpl(
//   CredentialsScope.GLOBAL,
//   "registry", "Docker Registry credentials",
//   "USERNAME",
//   "PASSWORD"
// )

store.addCredentials(domain, slavesPrivateKey)
store.addCredentials(domain, managersPrivateKey)
// store.addCredentials(domain, githubCredentials)
// store.addCredentials(domain, registryCredentials)
