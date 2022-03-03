terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
}

resource "aws_instance" "tf-example" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "TF-example"
  }
}
