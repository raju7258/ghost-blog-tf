variable "var_alb_sg" {
  
}

variable "env" {
  
}

variable "var_public_subnets" {

}

variable "var_vpcid" {
  
}


variable "targetgroups" {
  type = map(any)
  default = {
    tg1 = {
      name     = "ghost-alb"
      port     = "2368"
      protocol = "HTTP"
    },
    tg2 = {
      name     = "ghost-alb-2"
      port     = "2368"
      protocol = "HTTP"
    }
  }
}

variable "var_acm_pri_alb" {
  
}

variable "var_hostnames" {
  
}

# variable "var_ecs_server_id" {
  
# }