resource "aws_db_parameter_group" "stg-rds" {
  name   = "stg-rds"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
}
resource "aws_db_subnet_group" "stg-db-subnet-group-001" {
  name       = "stg-db-subnet-group-001"
  subnet_ids = [
    aws_subnet.public-a.id,
    aws_subnet.public-c.id,
    aws_subnet.public-d.id
  ]

  tags = {
    Name = "stg-db-subnet-group-001"
  }
}
resource "aws_db_instance" "stg-matsuhub-rds" {
  identifier           = "stg-matsuhub-rds"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "root"
  password             = var.stg_rds_root_password
  parameter_group_name = aws_db_parameter_group.stg-rds.name
  skip_final_snapshot  = true
  allocated_storage     = 50
  max_allocated_storage = 100
  db_subnet_group_name = aws_db_subnet_group.stg-db-subnet-group-001.name
#  deletion_protection = "true"
  vpc_security_group_ids = [
     aws_security_group.default_stg.id
  ]
}
