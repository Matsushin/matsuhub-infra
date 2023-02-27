resource "aws_instance" "stg-app-001" {
  ami                  = var.images["ap-northeast-1"]
  instance_type        = "t3a.medium"
  key_name             = var.key_name
  monitoring             = true
  vpc_security_group_ids = [
    aws_security_group.default_stg.id,
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id,
    aws_security_group.allow_api.id,
    aws_security_group.allow_all_outbound.id
  ]
  subnet_id                   = aws_subnet.public-a.id
  associate_public_ip_address = "true"
  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
  }
  tags = {
    Name = "stg-app-001"
  }
}

resource "aws_eip" "stg-app-002-eip" {
  instance = aws_instance.stg-app-001.id
  vpc      = true
}

resource "aws_eip" "stg-app-001-a-eip" {
  vpc      = true
  tags = {
    Name = "stg-app-eip-001-a"
  }
}

resource "aws_eip" "stg-app-001-c-eip" {
  vpc      = true
  tags = {
    Name = "stg-app-eip-001-c"
  }
}
