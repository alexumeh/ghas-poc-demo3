#https://github.com/hashicorp/terraform/releases
terraform {
  required_version = "~> 1.9.5"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "modus-create-s3-demo-2024-09-15-i"
  tags = {
    Name        = "modus bucket demo"
    Environment = "dev"
  }
}
