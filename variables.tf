variable "var_region" {
  description = "Enter Region Name"
  default = "us-east-1"
  type = string
}

variable "var_secondary_region" {
  type = string
  default = "us-east-2"
  
}

variable "var_profile" {
  description = "Enter Profile Name"
  default = "default"
  type = string
}

variable "var_vpc_cidr" {
  type = string
  default = "10.10.0.0/16"
}

variable "env" {
  type = string
  default = "dev"
}

variable "acm_pri_alb" {
  type    = string
  default = ""
}

variable "acm_sec_alb" {
  type    = string
  default = ""
}

variable "acm_cf" {
  type = string
  default = ""
}


variable "hostnames" {
  type = string
  default = ""
}


variable "var_dr_env" {
  type = string
  default = "dev-dr"
}


variable "lambda_function_name" {
  type = string
  default = "ghost-dev-lambda"
}
