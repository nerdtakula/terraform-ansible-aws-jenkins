output "public_ip" {
  value       = module.jenkins.public_ip
  description = "IP address of the Jenkins instance"
}
