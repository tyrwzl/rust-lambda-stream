
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Service     = var.service_name
    }
  }
}


provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
  default_tags {
    tags = {
      Service     = var.service_name
    }
  }
}
