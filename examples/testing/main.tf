/*
 * Set global valirables
 */
locals {
  # General Info
  namespace = "tak"
  name      = "jenkins"
  stage     = "dev"
  region    = "us-west-2" # Oregon
}

/*
 * Configure out AWS connection
 */
provider "aws" {
  region = local.region
}

/*
 * Define the ssh key
 */
resource "aws_key_pair" "ssh_key" {
  key_name   = "${local.namespace}-${local.stage}-${local.name}-ssh-key"
  public_key = file("id_rsa.pub")
}


module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.1"
  namespace  = local.namespace
  stage      = local.stage
  name       = local.name
  cidr_block = "10.10.0.0/16"
}

module "jenkins" {
  source                 = "git::https://github.com:nerdtakula/terraform-ansible-aws-jenkins.git"
  namespace              = local.namespace
  stage                  = local.stage
  name                   = local.name
  master_instance_type   = "t2.medium"
  slave_instance_type    = "t2.medium"
  region                 = local.region
  ssh_key_pair           = aws_key_pair.ssh_key.key_name
  private_ssh_key        = "id_rsa"
  vpc_id                 = module.vpc.vpc_id
  igw_id                 = module.vpc.igw_id
  ssl_cert_file          = "jenkins.nerdtakula.com.crt"
  ssl_cert_key           = "jenkins.nerdtakula.com.key"
  domain_name            = "jenkins.nerdtakula.com"
  jenkins_username       = "admin"
  jenkins_password       = "admin"
  jenkins_credentials_id = "aws-ec2-build-slave"
}
