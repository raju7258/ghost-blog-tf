output "out_nl_vpcid" {
    value = module.mod_ghost_vpc.vpc_id
    description = "VPC ID"
}

output "out_nl_privatesubnet" {
    value = module.mod_ghost_vpc.private_subnets
    description = "Private Subnets"
}

output "out_nl_publicsubnet" {
    value = module.mod_ghost_vpc.public_subnets
    description = "Public Subnets"
}

output "out_nl_rdssubnet" {
    value = module.mod_ghost_vpc.intra_subnets
    description = "RDS Subnets"
}

output "out_nl_vpccidr" {
    value = var.var_vpc
}