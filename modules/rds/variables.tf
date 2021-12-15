variable "rds_instance_type" {
  type = string
  default = "db.t3.small"
}

variable "engine" {
  type    = string
  default = "aurora"
}

variable "engineversion" {
  type    = string
  default = "5.6.10a"
}

variable "pgfamily" {
  type    = string
  default = "aurora5.6"
}

variable "masterusername" {
  type    = string
  default = "ghostadmin"
}

variable "backup_retention_period" {
  type    = number
  default = 5
}

variable "preferred_backup_window" {
  type    = string
  default = "07:00-09:00"
}

variable "var_vpc_security_group_ids" {
}

variable "var_subnet_ids" {
}

variable "var_kmsarn" {
}

variable "env" {
}