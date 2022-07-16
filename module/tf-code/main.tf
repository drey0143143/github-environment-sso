resource "aws_vpc" "test" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "GithAction"
  }
}

resource "aws_kms_key" "test-kms-key" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "github-environment" {
  name          = "alias/myolukey-actions"
  target_key_id = aws_kms_key.test-kms-key.key_id
}


resource "aws_subnet" "GitAction-subnet" {
 vpc_id     = aws_vpc.test.id
cidr_block = "10.0.1.0/24"

tags = {
 Name = "Dev"
}
}


resource "aws_s3_bucket" "test" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "GitHub"
  }
}