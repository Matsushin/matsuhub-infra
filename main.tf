variable "admin_ips" {}
variable "vpc_cidr_block" {}
variable "subnet_a_cidr_block" {}
variable "subnet_c_cidr_block" {}
variable "subnet_d_cidr_block" {}
variable "key_name" {}
variable "app_name" {}
variable "ec2_default_arn" {}
variable "ec2_role" {}
variable "stg_rds_root_password" {}
variable "s3_zone_id" {}
variable "s3_zone_domain" {}
variable "AWS_ACCOUNT_ID" {}
variable "AWS_DEFAULT_REGION" {}
terraform {
  backend "s3" {
    bucket = "archive.matsuhub"
    region = "ap-northeast-1"
    key = "terraform/terraform.tfstate"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

variable "region" {
  default = "ap-northeast-1"
}
variable "az_a" {
  default = "ap-northeast-1a"
}
variable "az_c" {
  default = "ap-northeast-1c"
}
variable "az_d" {
  default = "ap-northeast-1d"
}
variable "images" {
  default = {
    ap-northeast-1 = "ami-0df99b3a8349462c6" # ubuntu20.04
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "Default_VPC" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "false"
  tags = {
    Name = "Default_VPC"
  }
}

resource "aws_internet_gateway" "defaultGW" {
  vpc_id = aws_vpc.Default_VPC.id
}

resource "aws_subnet" "public-a" {
  vpc_id            = aws_vpc.Default_VPC.id
  cidr_block        = var.subnet_a_cidr_block
  availability_zone = var.az_a
}

resource "aws_subnet" "public-c" {
  vpc_id            = aws_vpc.Default_VPC.id
  cidr_block        = var.subnet_c_cidr_block
  availability_zone = var.az_c
}
resource "aws_subnet" "public-d" {
  vpc_id            = aws_vpc.Default_VPC.id
  cidr_block        = var.subnet_d_cidr_block
  availability_zone = var.az_d
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.Default_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.defaultGW.id
  }
}

resource "aws_route_table_association" "puclic-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public-route.id
}
resource "aws_route_table_association" "puclic-c" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_route_table.public-route.id
}
resource "aws_route_table_association" "puclic-d" {
  subnet_id      = aws_subnet.public-d.id
  route_table_id = aws_route_table.public-route.id
}



#
# <cert for cloudfront>
# Cloudfront require certificate whose provider is "us-east-1"
#
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}
resource "aws_acm_certificate" "cert_global" {
  provider                  = aws.virginia
  domain_name               = var.s3_zone_domain
  subject_alternative_names = ["*.${var.s3_zone_domain}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

#
# </cert for cloudfront>
#


resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.s3_zone_domain}"
  subject_alternative_names = [var.s3_zone_domain]

  validation_method = "DNS"
  lifecycle {
     create_before_destroy = true
   }
  tags = {
    Name = "acm-cert"
  }

}
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  type = each.value.type
  ttl = "300"

  # レコードを追加するドメインのホストゾーンIDを指定
  zone_id = var.s3_zone_id
}
