include {
  path = find_in_parent_folders()
}

#terraform {
#  source = "../../../../modules/node-relay//"
#}

inputs = {
  aws_region = "ap-southeast-2"
  aws_instance_type  = "c5.xlarge"
  subnet_id = "subnet-099bdb73dcd32aad6"
  release = "22.11"
  cidr_blocks = ["xx.xx.xx.xx\32"]
}

