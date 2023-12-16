terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.1.0"
    }
  }

  backend "s3" {
    region         = "ap-northeast-1"
    bucket         = ""
    key            = "terraform.tfstate"
    dynamodb_table = ""
    encrypt        = true
  }
}
