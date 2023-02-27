resource "aws_security_group" "allow_all_outbound" {
  name        = "allow_all_outbound"
  description = "Allow all outbound traffic"
  vpc_id      = aws_vpc.Default_VPC.id
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = -1
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "icmp"
    security_groups  = []
    self             = false
    to_port          = -1
  }
}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.Default_VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "allow_api" {
  name        = "allow_api"
  description = "Allow api inbound traffic"
  vpc_id      = aws_vpc.Default_VPC.id
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http/https inbound traffic"
  vpc_id      = aws_vpc.Default_VPC.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "default_stg" {
  name        = "default_stg"
  description = "Allow all inbound traffic from staging env"
  vpc_id      = aws_vpc.Default_VPC.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups  = [aws_security_group.default_all.id]
  }
}

resource "aws_security_group" "default_all" {
  name        = "default_all"
  vpc_id      = aws_vpc.Default_VPC.id
  description = "Allow all inbound traffic from prod and stg env"
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }
}
