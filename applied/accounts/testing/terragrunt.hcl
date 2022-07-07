remote_state {
  backend = "s3"
  config = {
    bucket         = "github-environment-test"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
