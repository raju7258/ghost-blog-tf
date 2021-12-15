resource "aws_db_subnet_group" "subnetgroup" {
  name       = "ghost-${var.env}-subgrp"
  subnet_ids = var.var_subnet_ids
  description = "Subnet Group for ${var.env}"

  tags = {
    Name = "ghost-${var.env}-subgrp"
    Env = "${var.env}"
  }
}

resource "aws_db_parameter_group" "pg" {
  name   = "ghost-${var.env}-pg"
  family = var.pgfamily
  description = "Parameter group for ${var.env}"

  parameter {
    name  = "innodb_large_prefix"    
    value = 1
    apply_method = "pending-reboot"
  }
}

resource "aws_rds_cluster_parameter_group" "cpg" {
  name        = "ghost-${var.env}-cluster-pg"
  family      = var.pgfamily
  description = "Cluster Parameter group for ${var.env}"
  parameter {
    name  = "binlog_format"    
    value = "MIXED"
    apply_method = "pending-reboot"
  }
  parameter {
    name  = "innodb_large_prefix"    
    value = 1
    apply_method = "pending-reboot"
  }

  parameter {
    name = "log_bin_trust_function_creators"
    value = 1
    apply_method = "pending-reboot"
  }
}

#Generate random password for Aurora DB
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

#Store data in parameter store
resource "aws_ssm_parameter" "username" {
  name        = "/${var.env}/aurora/masterusername"
  description = "RDS Username for ${var.env} environment"
  type        = "SecureString"
  value       = var.masterusername

  tags = {
    environment = "${var.env}"
  }
}

resource "aws_ssm_parameter" "password" {
  name        = "/${var.env}/aurora/password"
  description = "RDS Password for ${var.env} environment"
  type        = "SecureString"
  value       = random_password.password.result

  tags = {
    environment = "${var.env}"
  }
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier      = "ghost-${var.env}"
  engine                  = var.engine
  engine_version          = var.engineversion
  database_name           = "ghost${var.env}"
  master_username         = var.masterusername
  master_password         = random_password.password.result
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  db_subnet_group_name    = aws_db_subnet_group.subnetgroup.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cpg.name

  vpc_security_group_ids  = ["${var.var_vpc_security_group_ids}"]
  skip_final_snapshot  = true
  storage_encrypted   = true
  kms_key_id         = var.var_kmsarn
  lifecycle {
    ignore_changes = [engine_version]
  }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier              = "ghost-${var.env}"
  cluster_identifier      = aws_rds_cluster.cluster.id
  instance_class          = var.rds_instance_type
  engine                  = aws_rds_cluster.cluster.engine
  engine_version          = aws_rds_cluster.cluster.engine_version
  db_parameter_group_name = aws_db_parameter_group.pg.name
}

