
data "aws_caller_identity" "current" {}

# module "mod_lambda" {
#   source = "./modules/lambda"
#   var_lambdarolearn = module.mod_iam_roles.out_lambdarolearn
#   var_hostnames = var.hostnames
#   var_lambda_kms = module.mod_kms.out_lambda_kms
#   env = var.env
#   var_lambda_function_name = var.lambda_function_name
#   var_region = var.var_region
# }

module "mod_cloudfront" {
  source  = "./modules/cloudfront"
  var_albdns = module.mod_alb.out_albdns
  var_sec_albdns = module.mod_alb_dr.out_albdns

  var_aliases = var.hostnames
  env = var.env
  var_acm = var.acm_cf

  wafid  = module.mod_wafv2.out_wafv2_id

  depends_on = [
    module.mod_alb,
    module.mod_alb_dr,
    module.mod_wafv2,
    module.mod_fargate,
    module.mod_fargate_dr,
    module.mod_codebuild,
    module.mod_codebuild_dr,
    module.mod_codedeploy,
    module.mod_codedeploy_dr,
    module.mod_codepipeline,
    module.mod_codepipeline_dr,
    module.mod_codestar,
    module.mod_codestar_dr,
    module.mod_s3,
    module.mod_s3_dr,
    module.mod_kms,
    module.mod_kms_dr,
    module.mod_iam_roles,
    module.mod_iam_policy,
    module.mod_iam_user,
    module.mod_sg,
    module.mod_sg_dr,
    module.mod_rds,
    module.mod_rds_dr,
    module.mod_ecr,
    module.mod_ecr_dr
  ]
}

module "mod_wafv2" {
  source = "./modules/wafv2"
  env = var.env
}

#VPC 
module "mod_vpc" {
    var_vpc = var.var_vpc_cidr
    source = "./modules/vpc"
    env = var.env
}

#KMS 
module "mod_kms" {
  source = "./modules/kms"
  var_secondary_region = var.var_secondary_region
  #var_kms_policy_id = module.mod_iam_policy.out_kms_policy_id
  var_s3replicationrolearn = module.mod_iam_roles.out_s3replicationrolearn
  
}

#Security Group
module "mod_sg" {
  source = "./modules/security_group"
  env = var.env
  var_vpcid = module.mod_vpc.out_nl_vpcid
  var_vpc_cidr = var.var_vpc_cidr
}

#RDS
module "mod_rds" {
  source = "./modules/rds"
  env = var.env
  var_kmsarn = module.mod_kms.out_aurora_kms
  var_subnet_ids = module.mod_vpc.out_nl_rdssubnet
  var_vpc_security_group_ids = module.mod_sg.out_rds_sg_id
  depends_on = [
    module.mod_kms,
    module.mod_sg,
    module.mod_vpc
  ]
}
#------------------------------
#CI/CD Pipeline Primary Region
#-------------------------------
#ECR Repo
module "mod_ecr" {
  source = "./modules/primary-codepipeline/ecr"
  env = var.env
}

#Codestar connection
module "mod_codestar" {
  source = "./modules/primary-codepipeline/codestar"
  env = var.env
}

#S3 for Artifacts
module "mod_s3" {
  source = "./modules/primary-codepipeline/s3"
  env = var.env
  var_s3_kms_arn = module.mod_kms.out_s3_kms
  var_s3_kms_sec_arn = module.mod_kms.out_s3_kms_sec
  var_secondary_region = var.var_secondary_region
  var_s3replicationrolearn = module.mod_iam_roles.out_s3replicationrolearn
}

#IAM Role
module "mod_iam_roles" {
  source = "./modules/primary-codepipeline/iam/roles"
}

#CodeBuild
module "mod_codebuild" {
  source = "./modules/primary-codepipeline/codebuild"
  env = var.env
  var_codebuild_arn = module.mod_iam_roles.out_codebuildrolearn
  var_ecr_url = module.mod_ecr.out_ecr_repo_url
  var_ecr_name = module.mod_ecr.out_ecr_repo_name
  var_ecs_container_name = module.mod_fargate.out_ecs_container_name
  var_ecstaskservice_rolearn = module.mod_iam_roles.out_ecstaskservicerolearn
  var_ssm_database_username = module.mod_rds.out_ssm_database_username
  var_ssm_database_password = module.mod_rds.out_ssm_database_password
  var_database_name = module.mod_rds.out_database_name
  var_database_writer_endpoint = module.mod_rds.out_database_writer_endpoint
  var_s3_content_assets_name = module.mod_s3.out_s3_content_assets_name
  var_ghost_content_user_access_key = module.mod_iam_user.out_ghost_content_user_access_key
  var_ghost_content_user_secret_access_key = module.mod_iam_user.out_ghost_content_user_secret_access_key
  var_td_family = module.mod_fargate.out_td_family
  var_ecs_task_definition_arn = module.mod_fargate.out_ecs_task_definition_arn
  var_ecs_task_definition_revision = module.mod_fargate.out_ecs_task_definition_revision
  var_hostnames = var.hostnames

  
  depends_on = [
    module.mod_iam_roles,
    module.mod_ecr,
    module.mod_fargate,
    module.mod_rds
  ]
}

#IAM User for Ghost Content access
module "mod_iam_user" {
  source = "./modules/primary-codepipeline/iam/user"
  env = var.env

}

#IAM Policy for CodePipeline Role and CodeBuild Role
module "mod_iam_policy" {
  source = "./modules/primary-codepipeline/iam/policy"
  env = var.env
  var_codestar_arn = module.mod_codestar.out_codestar_arn
  var_s3_codepipeline_artifacts_arn = module.mod_s3.out_s3_codepipeline_artifacts_arn
  var_codepipeline_rolename = module.mod_iam_roles.out_codepipelinerole
  var_codebuild_arn = module.mod_codebuild.out_codebuild_arn
  var_codebuild_rolename = module.mod_iam_roles.out_codebuildrole
  var_region = var.var_region
  var_ecr_arn = module.mod_ecr.out_ecr_arn
  var_ghost_content_user_name = module.mod_iam_user.out_ghost_content_user_name
  var_ghost_content_user_arn = module.mod_iam_user.out_ghost_content_user_arn
  var_ecstaskservice_rolename = module.mod_iam_roles.out_ecstaskservicerolename
  var_s3_content_assets_arn = module.mod_s3.out_s3_content_assets_arn
  var_s3_content_assets_arn_destination = module.mod_s3.out_s3_content_assets_arn_destination
  var_codedeploy_rolename = module.mod_iam_roles.out_codedeployrolename
  var_codedeploy_app_arn = module.mod_codedeploy.out_codedeploy_app_arn
  var_s3replicationrolename = module.mod_iam_roles.out_s3replicationrolename
  var_lambdarolename = module.mod_iam_roles.out_lambdarolename
  

  depends_on = [
    module.mod_iam_roles,
    module.mod_codebuild,
    module.mod_s3,
    module.mod_codestar,
    module.mod_ecr,
    module.mod_iam_user
  ]
}



#CodePipeline
module "mod_codepipeline" {
  source = "./modules/primary-codepipeline/codepipeline"
  env = var.env
  var_codestar_arn = module.mod_codestar.out_codestar_arn
  var_s3_codepipeline_artifacts = module.mod_s3.out_s3_codepipeline_artifacts
  var_codepipeline_rolearn = module.mod_iam_roles.out_codepipelinerolearn
  var_codebuild_id = module.mod_codebuild.out_codebuild_id
  var_codedeploy_appname = module.mod_codedeploy.out_codedeploy_appname
  var_codedeploy_groupname = module.mod_codedeploy.out_codedeploy_groupname

  depends_on = [
    module.mod_iam_roles,
    module.mod_s3,
    module.mod_codestar,
    module.mod_iam_policy,
    module.mod_codebuild,
    module.mod_codedeploy
  ]

}

#ALB
module "mod_alb" {
  source = "./modules/primary-codepipeline/alb"
  env = var.env
  var_alb_sg = module.mod_sg.out_alb_sg_id
  var_public_subnets = module.mod_vpc.out_nl_publicsubnet
  var_vpcid = module.mod_vpc.out_nl_vpcid
  var_acm_pri_alb = var.acm_pri_alb
  var_hostnames = var.hostnames

  depends_on = [
    module.mod_vpc,
    module.mod_sg,
    module.mod_s3
  ]
}

#Fargate 
module "mod_fargate" {
  source = "./modules/primary-codepipeline/fargate"
  env = var.env
  var_region = var.var_region
  var_hostnames = var.hostnames
  var_awsaccount = data.aws_caller_identity.current.account_id
  var_ecstaskservice_rolearn = module.mod_iam_roles.out_ecstaskservicerolearn
  var_ghost_content_user_access_key = module.mod_iam_user.out_ghost_content_user_access_key
  var_ghost_content_user_secret_access_key = module.mod_iam_user.out_ghost_content_user_secret_access_key
  var_cluster_identifier = module.mod_rds.out_cluster_identifier
  var_ssm_database_username = module.mod_rds.out_ssm_database_username
  var_ssm_database_password = module.mod_rds.out_ssm_database_password
  var_s3_content_assets_arn = module.mod_s3.out_s3_content_assets_arn
  var_alb_tg_arn = module.mod_alb.out_alb_tg_arn
  var_nl_privatesubnet = module.mod_vpc.out_nl_privatesubnet
  var_fargate_sg_id = module.mod_sg.out_fargate_sg_id
  var_ecr_url = module.mod_ecr.out_ecr_repo_url
  
  depends_on = [
    module.mod_alb,
    module.mod_s3,
    module.mod_rds,
    module.mod_iam_user,
    module.mod_iam_roles,
    module.mod_sg
  ]

}

#CodeDeploy
module "mod_codedeploy" {
  source = "./modules/primary-codepipeline/codedeploy"
  env = var.env
  var_codedeploy_rolearn = module.mod_iam_roles.out_codedeployrolearn
  var_ecs_cluster_name = module.mod_fargate.out_ecs_cluster_name
  var_ecs_service_name = module.mod_fargate.out_ecs_service_name
  var_alb_listener_arn = module.mod_alb.out_alb_listener_arn
  var_alb_tg_name = module.mod_alb.out_alb_tg_name
  var_alb_tg2_name = module.mod_alb.out_alb_tg2_name

  depends_on = [
    module.mod_alb,
    module.mod_fargate,
    module.mod_iam_roles
  ]
}

#cloudwatch logs
module "mod_cwlogs" {
  source = "./modules/primary-codepipeline/cloudwatch/logs"
  env = var.env
  var_td_family = module.mod_fargate.out_td_family
  var_lambda_function_name = var.lambda_function_name
}

#-----------
# DR Infra
#---------

#VPC 
module "mod_vpc_dr" {
  source = "./modules/dr/vpc"
  providers = {
    aws = aws.secondary
   }
}

#KMS
module "mod_kms_dr" {
  source = "./modules/dr/kms"
  providers = {
    aws = aws.secondary
  }
  var_secondary_region = var.var_secondary_region
  
}

#Security Group
module "mod_sg_dr" {
  source = "./modules/dr/security_group"
  providers = {
    aws = aws.secondary
  }
  var_vpcid = module.mod_vpc_dr.out_nl_vpcid
  var_vpc_cidr = module.mod_vpc_dr.out_nl_vpccidr
}

#RDS
module "mod_rds_dr" {
  source = "./modules/dr/rds"
  providers = {
    aws = aws.secondary
   }
  var_kmsdrarn = module.mod_kms_dr.out_aurora_kms_dr
  var_subnet_ids = module.mod_vpc_dr.out_nl_rdssubnet
  var_vpc_security_group_ids = module.mod_sg_dr.out_rds_sg_id
  depends_on = [
    module.mod_kms_dr,
    module.mod_sg_dr,
    module.mod_vpc_dr,
    module.mod_rds
  ]
  var_replication_source_identifier = module.mod_rds.out_cluster_arn
}

#-----------------------------
#CI/CD Pipeline Secondary Region
#--------------------------------

#Codestar Connection
module "mod_codestar_dr" {
  source = "./modules/dr/codestar"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
}

#ECR Repository
module "mod_ecr_dr" {
  source = "./modules/dr/ecr"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
}

#ALB 
module "mod_alb_dr" {
  source = "./modules/dr/alb"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
  var_alb_sg = module.mod_sg_dr.out_alb_sg_id
  var_public_subnets = module.mod_vpc_dr.out_nl_publicsubnet
  var_vpcid = module.mod_vpc_dr.out_nl_vpcid
  var_acm_sec_alb = var.acm_sec_alb
  var_hostnames = var.hostnames
  var_alb_sec_logs = module.mod_s3_dr.out_alb_sec_logs


  depends_on = [
    module.mod_vpc_dr,
    module.mod_sg_dr,
    module.mod_s3_dr
  ]
}


#Fargate
module "mod_fargate_dr" {
  source = "./modules/dr/fargate"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
  var_hostnames = var.hostnames
  var_region = var.var_secondary_region
  var_awsaccount = data.aws_caller_identity.current.account_id
  var_ecstaskservice_rolearn = module.mod_iam_roles.out_ecstaskservicerolearn
  var_ghost_content_user_access_key = module.mod_iam_user.out_ghost_content_user_access_key
  var_ghost_content_user_secret_access_key = module.mod_iam_user.out_ghost_content_user_secret_access_key
  var_cluster_identifier = module.mod_rds_dr.out_cluster_identifier
  var_ssm_database_username = module.mod_rds.out_ssm_database_username_value
  var_ssm_database_password = module.mod_rds.out_ssm_database_password_value
  var_s3_content_assets_arn = module.mod_s3.out_s3_content_assets_name_destination
  var_nl_privatesubnet = module.mod_vpc_dr.out_nl_privatesubnet
  var_ecr_url = module.mod_ecr_dr.out_ecr_repo_url
  var_alb_tg_arn = module.mod_alb_dr.out_alb_tg_arn
  var_fargate_sg_id = module.mod_sg_dr.out_fargate_sg_id
  depends_on = [
    module.mod_alb_dr,
    module.mod_s3,
    module.mod_rds_dr,
    module.mod_iam_user,
    module.mod_iam_roles,
    module.mod_sg_dr
  ]

}

#CodeBuild
module "mod_codebuild_dr" {
  source = "./modules/dr/codebuild"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
  var_codebuild_arn = module.mod_iam_roles.out_codebuildrolearn
  var_ecr_url = module.mod_ecr_dr.out_ecr_repo_url
  var_ecr_name = module.mod_ecr_dr.out_ecr_repo_name
  var_accountID = data.aws_caller_identity.current.account_id
  var_ecs_container_name = module.mod_fargate_dr.out_ecs_container_name
  var_ecstaskservice_rolearn = module.mod_iam_roles.out_ecstaskservicerolearn
  var_ssm_database_username = module.mod_rds.out_ssm_database_username_value
  var_ssm_database_password = module.mod_rds.out_ssm_database_password_value
  var_database_name = module.mod_rds.out_database_name
  var_database_writer_endpoint = module.mod_rds_dr.out_database_writer_endpoint
  var_s3_content_assets_name = module.mod_s3.out_s3_content_assets_name_destination
  var_ghost_content_user_access_key = module.mod_iam_user.out_ghost_content_user_access_key
  var_ghost_content_user_secret_access_key = module.mod_iam_user.out_ghost_content_user_secret_access_key
  var_td_family = module.mod_fargate_dr.out_td_family
  var_ecs_task_definition_arn = module.mod_fargate_dr.out_ecs_task_definition_arn
  var_ecs_task_definition_revision = module.mod_fargate_dr.out_ecs_task_definition_revision
  var_hostnames = var.hostnames

  
  depends_on = [
    module.mod_iam_roles,
    module.mod_ecr_dr,
    module.mod_fargate_dr,
    module.mod_rds_dr
  ]
}

#S3 for ALB Logs
module "mod_s3_dr" {
  source = "./modules/dr/s3"
  env = var.var_dr_env
  providers = {
    aws = aws.secondary
  }
  var_s3_kms_sec_arn = module.mod_kms.out_s3_kms_sec

  depends_on = [
    module.mod_kms
  ]
}

#CodeDeploy
module "mod_codedeploy_dr" {
  source = "./modules/dr/codedeploy"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
  var_codedeploy_rolearn = module.mod_iam_roles.out_codedeployrolearn
  var_ecs_cluster_name = module.mod_fargate_dr.out_ecs_cluster_name
  var_ecs_service_name = module.mod_fargate_dr.out_ecs_service_name
  var_alb_listener_arn = module.mod_alb_dr.out_alb_listener_arn
  var_alb_tg_name = module.mod_alb_dr.out_alb_tg_name
  var_alb_tg2_name = module.mod_alb_dr.out_alb_tg2_name

  depends_on = [
    module.mod_alb_dr,
    module.mod_fargate_dr,
    module.mod_iam_roles
  ]
}

#cloudwatch logs
module "mod_cwlogs_dr" {
  source = "./modules/dr/cloudwatch/logs"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
  var_td_family = module.mod_fargate_dr.out_td_family
}

#CodePipeline
module "mod_codepipeline_dr" {
  source = "./modules/dr/codepipeline"
  providers = {
    aws = aws.secondary
  }
  env = var.var_dr_env
  var_codestar_arn = module.mod_codestar_dr.out_codestar_arn
  var_s3_codepipeline_artifacts = module.mod_s3_dr.out_s3_codepipeline_artifacts
  var_codepipeline_rolearn = module.mod_iam_roles.out_codepipelinerolearn
  var_codebuild_id = module.mod_codebuild_dr.out_codebuild_id
  var_codedeploy_appname = module.mod_codedeploy_dr.out_codedeploy_appname
  var_codedeploy_groupname = module.mod_codedeploy_dr.out_codedeploy_groupname

  depends_on = [
    module.mod_iam_roles,
    module.mod_s3_dr,
    module.mod_codestar_dr,
    module.mod_iam_policy,
    module.mod_codebuild_dr,
    module.mod_codedeploy_dr
  ]

}
