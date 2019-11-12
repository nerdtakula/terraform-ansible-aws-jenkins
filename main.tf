/*
 * Public Subnet for Jenkins and Build Slaves
 */
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  map_public_ip_on_launch = true
  cidr_block              = var.public_subnet_cidr

  tags = {
    Name      = "${var.namespace}-${var.stage}-${var.name}-public-subnet"
    Service   = var.name
    NameSpace = var.namespace
    Stage     = var.stage
  }
}


resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name      = "${var.namespace}-${var.stage}-${var.name}-public-route-table"
    Service   = var.name
    NameSpace = var.namespace
    Stage     = var.stage
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id
  subnet_ids = [aws_subnet.public.id]

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
  }

  tags = {
    Name      = "${var.namespace}-${var.stage}-${var.name}-public-network-acl"
    Service   = var.name
    NameSpace = var.namespace
    Stage     = var.stage
  }
}

/*
 * Elastic IP for Jenkins master
 */
resource "aws_eip" "default" {
  instance = aws_instance.jenkins_master.id
  vpc      = true

  tags = {
    Name      = "${var.namespace}-${var.stage}-${var.name}-eip"
    Service   = var.name
    NameSpace = var.namespace
    Stage     = var.stage
  }
}

/*
 * Lookup up Ubuntu AMI for jenkins servers
 */
data "aws_ami" "ubuntu" {
  owners = ["099720109477"] # Canonical User (https://canonical.com/)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
}

/*
 * Create Jenkins Master instance
 */
resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.master_instance_type
  key_name                    = var.ssh_key_pair
  vpc_security_group_ids      = [aws_security_group.jenkins_master.id]
  subnet_id                   = aws_subnet.public.id
  monitoring                  = true
  associate_public_ip_address = true
  source_dest_check           = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  # Ansible requires Python to be installed on the remote machine
  provisioner "remote-exec" {
    inline = ["sudo apt-get install -qq -y python"]
  }

  # Install & Configure via Ansible Playbook
  provisioner "local-exec" {
    command = <<EOT
echo "[jenkins_master]" > ./ansible-${var.namespace}-${var.stage}-${var.name}.inventory;
echo "${aws_instance.jenkins_master.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_ssh_key}" >> ./ansible-${var.namespace}-${var.stage}-${var.name}.inventory;
echo "" >> ./ansible-${var.namespace}-${var.stage}-${var.name}.inventory;
echo "[jenkins_master:vars]" >> ./ansible-${var.namespace}-${var.stage}-${var.name}.inventory;
echo "ssl_cert = ${var.ssl_cert_file}" >> ./ansible-${var.namespace}-${var.stage}-${var.name}.inventory;
echo "ssl_key = ${var.ssl_cert_key}" >> ./ansible-${var.namespace}-${var.stage}-${var.name}.inventory;
%{for k, v in var.ansible_vars~}
echo "${k} = ${v}" >> ./ansible-${var.namespace}-${var.stage}-${var.name}.inventory;
%{endfor~}
EOT
  }

  connection {
    type        = "ssh"
    private_key = file(var.private_ssh_key)
    user        = var.ansible_user
    host        = aws_instance.jenkins_master.public_ip
  }

  tags = {
    Name      = "${var.namespace}-${var.stage}-${var.name}-master"
    Service   = var.name
    NameSpace = var.namespace
    Stage     = var.stage
  }

  volume_tags = {
    Name      = "${var.namespace}-${var.stage}-${var.name}-master-root-volume"
    Service   = var.name
    NameSpace = var.namespace
    Stage     = var.stage
  }
}

/*
 * Create Jenkins Master Decurity Group
 */
resource "aws_security_group" "jenkins_master" {
  name   = "${var.namespace}-${var.stage}-${var.name}-master-sec-grp"
  vpc_id = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound ICMP (Ping) requests
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins slave agent port
  ingress {
    from_port   = 50022
    to_port     = 50022
    protocol    = "tcp"
    cidr_blocks = [var.public_subnet_cidr]
  }

  # Inbound SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.namespace}-${var.stage}-${var.name}-master-sec-grp"
    Service   = var.name
    NameSpace = var.namespace
    Stage     = var.stage
  }
}
