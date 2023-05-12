remote_state {
  backend = "s3"
  config = {
    bucket         = "yumi-terraform-state-sandbox"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    dynamodb_table = "my-lock-table-sandbox"
  }
}
