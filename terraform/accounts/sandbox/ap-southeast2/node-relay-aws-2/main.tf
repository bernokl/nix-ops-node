terraform {
  backend "s3" {}
}

module "node-relay" {
  source = "../../../../modules/node-relay/"
  aws_region = var.aws_region
  aws_instance_type = var.aws_instance_type
  subnet_id = var.subnet_id
  release = var.release
  cidr_blocks = var.cidr_blocks
}

output "public_dns" {
  value = module.node-relay.public_dns
}
