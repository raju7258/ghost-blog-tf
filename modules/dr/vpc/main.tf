#AZ 
data "aws_availability_zones" "available" {
  state = "available"
}

#Subnetting 
module "mod_subnet_addr" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = var.var_vpc
  networks = [
    {
      name     = "Public Subnet 1"
      new_bits = 8
    },
    {
      name     = "Public Subnet 2"
      new_bits = 8
    },
    {
      name     = "Private Subnet 1"
      new_bits = 8
    },
    {
      name     = "Private Subnet 2"
      new_bits = 8
    },
    {
      name     = "RDS Subnet 1"
      new_bits = 8
    },
    {
      name     = "RDS Subnet 2"
      new_bits = 8
    }
  ]
}

#VPC Creation
module "mod_ghost_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = "${var.env}-vpc"
  cidr = var.var_vpc

  azs = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets = [module.mod_subnet_addr.network_cidr_blocks["Public Subnet 1"],module.mod_subnet_addr.network_cidr_blocks["Public Subnet 2"]]
  private_subnets = [module.mod_subnet_addr.network_cidr_blocks["Private Subnet 1"],module.mod_subnet_addr.network_cidr_blocks["Private Subnet 2"]]
  intra_subnets = [module.mod_subnet_addr.network_cidr_blocks["RDS Subnet 1"],module.mod_subnet_addr.network_cidr_blocks["RDS Subnet 2"]]

  enable_nat_gateway = true
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support = true

  public_subnet_tags = {
    Name = "Public Subnets-${var.env}"
    Environment = "${var.env}"
  }
  private_subnet_tags = {
    Name = "Private Subnets-${var.env}"
    Environment = "${var.env}"
  }

  intra_subnet_tags = {
    Name = "RDS Subnets-${var.env}"
    Environment = "${var.env}"
  }

  igw_tags = {
      Name = "${var.env}-IGW"
      Environment = "${var.env}"
  }
  nat_gateway_tags = {
      Name = "${var.env}-NAT-GW"
      Environment = "${var.env}"
  }
}

