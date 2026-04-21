import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.*
import hudson.plugins.git.*

def instance = Jenkins.getInstance()

// 1. Create Admin User
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin123")
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()

// 2. Create Pipeline Job
def jobName = "app_pipeline"
if (instance.getItem(jobName) == null) {
    def job = new WorkflowJob(instance, jobName)
    def scm = new GitSCM("http://gitea:3000/admin/app_repo.git")
    scm.branches = [new hudson.plugins.git.BranchSpec("*/main")]
    def flowDefinition = new CpsScmFlowDefinition(scm, "Jenkinsfile")
    flowDefinition.setLightweight(true)
    job.setDefinition(flowDefinition)
    instance.add(job, jobName)
    job.save()
}
