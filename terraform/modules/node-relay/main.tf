variable "aws_region" {}
variable "aws_instance_type" {}
variable "subnet_id" {}
variable "release" {}
variable "cidr_blocks" {}

provider "aws" {
    region = var.aws_region
}

module "nixos_image" {
    source  = "git::https://github.com/bernokl/terraform-nixos.git//aws_image_nixos?ref=c8746e7a74f6e9c2c66c3492098c576758e987e8"
    release = var.release
}

resource "aws_security_group" "ssh_and_egress" {
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.cidr_blocks
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "tls_private_key" "state_ssh_key" {
    algorithm = "RSA"
}

resource "local_sensitive_file" "machine_ssh_key" {
    content = tls_private_key.state_ssh_key.private_key_pem
    filename          = "${path.module}/id_rsa.pem"
    file_permission   = "0600"
}

resource "aws_key_pair" "generated_key" {
    key_name   = "generated-key-${sha256(tls_private_key.state_ssh_key.public_key_openssh)}"
    public_key = tls_private_key.state_ssh_key.public_key_openssh
}

resource "aws_instance" "machine" {
    ami                    = module.nixos_image.ami
    instance_type          = var.aws_instance_type
    vpc_security_group_ids = [ aws_security_group.ssh_and_egress.id ]
    key_name               = aws_key_pair.generated_key.key_name
    subnet_id              = var.subnet_id
    associate_public_ip_address = true
    root_block_device {
        volume_size  = 50 # GiB
    }
    user_data = "${file("start_node.sh")}"
}

output "public_dns" {
    value = aws_instance.machine.public_dns
}

module "deploy_nixos" {
    source = "git::https://github.com/bernokl/terraform-nixos.git//deploy_nixos?ref=5f5a0408b299874d6a29d1271e9bffeee4c9ca71"
    nixos_config = "${path.module}/configuration.nix"
    target_host = aws_instance.machine.public_ip
    ssh_private_key_file = local_sensitive_file.machine_ssh_key.filename
    ssh_agent = false
}

