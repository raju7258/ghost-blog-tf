
resource "aws_security_group" "rds_sg" {
  name        = "Ghost RDS SG for ${var.env}"
  description = "Ghost Security Groups for ${var.env}"
  vpc_id      = var.var_vpcid
  

  ingress {
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    cidr_blocks     = [var.var_vpc_cidr]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "RDS SG for ${var.env}"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "Ghost ALB SG for ${var.env}"
  description = "Ghost Security Groups for ${var.env}"
  vpc_id      = var.var_vpcid
  

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = "443"
    to_port         = "443"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "ALB SG for ${var.env}"
  }
}


resource "aws_security_group" "fargate_sg" {
  name        = "Ghost Fargate SG for ${var.env}"
  description = "Ghost Fargate Service Security Groups for ${var.env}"
  vpc_id      = var.var_vpcid
  

  ingress {
    protocol        = "tcp"
    from_port       = "2368"
    to_port         = "2368"
    security_groups     = [aws_security_group.alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Fargate Service SG for ${var.env}"
  }
}