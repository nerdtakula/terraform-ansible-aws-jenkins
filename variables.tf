variable "region" {
  type        = string
  description = "EC2 Region for the VPC"
  default     = "us-west-1"
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
  default     = "tak"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  default     = "test"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
  default     = "jenkins"
}

variable "description" {
  type        = string
  description = "Will be used as Elastic Compute Cloud application description"
  default     = "Ubuntu 18.04 Linux running Jenkins Server"
}

variable "ssh_key_pair" {
  type        = string
  description = "SSH Public key to be applied to Jenkins instances"
  default     = "id_rsa.pub"
}

variable "private_ssh_key" {
  type        = string
  description = "SSH Private key for SSH actions"
  default     = "id_rsa"
}

variable "master_instance_type" {
  type        = string
  description = "EC2 instance type for Jenkins master, e.g. 't2.medium'"
  default     = "t2.medium"
}

variable "slave_instance_type" {
  type        = string
  description = "EC2 instance type for Jenkins Slaves, e.g. 't2.medium'"
  default     = "t2.medium"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC in which to provision the AWS resources"
}

variable "igw_id" {
  type        = string
  description = "ID of the Internet Gateway"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the Public Subnet"
  default     = "10.0.0.0/24"
}

variable "ssl_cert_file" {
  type        = string
  description = "SSL cert file for website"
}

variable "ssl_cert_key" {
  type        = string
  description = "SSL cert KEY file for website"
}

variable "jenkins_version" {
  type        = string
  description = "Version of jenkins to be installed"
  default     = "2.190.2-slim"
}

variable "domain_name" {
  type        = string
  description = "Domain name to use within configuration"
}

variable "jenkins_username" {
  type        = string
  description = "Username for Jenkins Admin"
}

variable "jenkins_password" {
  type        = string
  description = "Password of Jenkins Admin"
}

variable "jenkins_credentials_id" {
  type        = string
  description = "Jenkins Slave Credentials ID"
  default     = "jenkins_ec2_slave_key"
}

variable "min_jenkins_slaves" {
  type        = string
  description = "Minimum number of jenkins slaves to start"
  default     = 1
}

variable "max_jenkins_slaves" {
  type        = string
  description = "Max number of jenkins slaves that can be started"
  default     = 4
}

variable "ansible_user" {
  type        = string
  description = "username of the root user on the EC2 instance"
  default     = "ubuntu"
}

variable "ansible_vars" {
  type        = map
  description = "variables to pass though to ansible playbook for gitlab instance"
  default     = {}
}
