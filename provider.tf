#dev region

provider "aws" {
    region = var.var_region
}

provider "aws" {
    region = var.var_secondary_region
    alias = "secondary"
}