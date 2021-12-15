provider "aws" {
  alias = "secondary"
  
  region = var.var_secondary_region
}