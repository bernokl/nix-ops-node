terraform {
  backend "s3" {}
}

provider "aws" {
    region = "ap-southeast-2"
}
# TODO: AUTOMATE THIS IMAGE LOOKUP, or find cache with aws/ami-/region table
# ref at the end is simple commit hash ie "git log" commit hash
module "nixos_image" {
    source  = "git::https://github.com/bernokl/terraform-nixos.git//aws_image_nixos?ref=b67bbc118f0d09ded8337e95c166d655d6d811ab"
    release = "22.11"
}

resource "aws_security_group" "ssh_and_egress" {
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["xx.xx.xx.xx/32"]
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
# This is first pass at pulling a secret out, will need to play
data "aws_secretsmanager_secret_version" "kes_secret" {
  secret_id = "arn:aws:secretsmanager:ap-southeast-2:407250907589:secret:testnet/kes.skey-LR7hrJ"
}
data "aws_secretsmanager_secret_version" "vrf_secret" {
  secret_id = "arn:aws:secretsmanager:ap-southeast-2:407250907589:secret:testnet/vrf.skey-2I4d7Y"
}
data "aws_secretsmanager_secret_version" "cert_secret" {
  secret_id = "arn:aws:secretsmanager:ap-southeast-2:407250907589:secret:testnet/node.cert-Vq66Lh"
}

resource "aws_instance" "machine" {
    ami                    = module.nixos_image.ami
    instance_type          = "${var.aws_instance_type}"
    vpc_security_group_ids = [ aws_security_group.ssh_and_egress.id ]
    key_name               = aws_key_pair.generated_key.key_name
    subnet_id              = "subnet-099bdb73dcd32aad6"
    associate_public_ip_address = true
    root_block_device {
        volume_size  = 50 # GiB
    }

  user_data = "${file("start_node.sh")}"
  connection {
    type        = "ssh"
    host        = aws_instance.machine.public_ip
    user        = "root"
    private_key = file("${path.module}/id_rsa.pem")
  }
  provisioner "remote-exec" {

    inline = [
      "echo '${data.aws_secretsmanager_secret_version.cert_secret.secret_string}' > /run/node_cert",
      "echo '${data.aws_secretsmanager_secret_version.vrf_secret.secret_string}' > /run/vrf_secret",
      "echo '${data.aws_secretsmanager_secret_version.kes_secret.secret_string}' > /run/kes_secret",
    ]
  }

}


output "public_dns" {
    value = aws_instance.machine.public_dns
}

module "deploy_nixos" {
    source = "git::https://github.com/bernokl/terraform-nixos.git//deploy_nixos?ref=b67bbc118f0d09ded8337e95c166d655d6d811ab"
    nixos_config = "${path.module}/configuration.nix"
    target_host = aws_instance.machine.public_ip
    ssh_private_key_file = local_sensitive_file.machine_ssh_key.filename
    ssh_agent = false
## IMPORTANT, you need this for repo configuration.nix to be applied to any ec2 changes.
    depends_on = [aws_instance.machine]
}



variable "aws_instance_type" {}
