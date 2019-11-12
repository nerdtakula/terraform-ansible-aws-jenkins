output "jenkins_public_ip" {
  value       = aws_instance.jenkins_master.public_ip
  description = "IP address of the Jenkins instance"
}

output "public_ip" {
  value       = aws_eip.default.public_ip
  description = "Elastic IP address of the Jenkins instance"
}

output "public_dns" {
  value       = aws_eip.default.public_dns
  description = "Elastic DNS address of the Jenkins instance"
}
