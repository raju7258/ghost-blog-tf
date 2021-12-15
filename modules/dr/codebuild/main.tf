resource "aws_codebuild_project" "codebuild" {
    name = "ghost-${var.env}-codebuild"
    service_role = var.var_codebuild_arn

    artifacts {
        type = "CODEPIPELINE"
    }
    environment {
        compute_type                = "BUILD_GENERAL1_MEDIUM"
        image                       = "aws/codebuild/standard:5.0"
        type                        = "LINUX_CONTAINER"
        privileged_mode             = true
        image_pull_credentials_type = "CODEBUILD"
        environment_variable {
            name = "REPOSITORY_URI"
            value = var.var_ecr_url
        }
        environment_variable {
            name = "AWS_ACCOUNT_ID"
            value = var.var_accountID
        }
        environment_variable {
            name = "IMAGE_REPO_NAME"
            value = var.var_ecr_name
        }
        environment_variable {
            name = "GHOST_CONTAINER_NAME"
            value = var.var_ecs_container_name
        }
        environment_variable {
            name = "IMAGE_TAG"
            value = "latest"
        }
        environment_variable {
          name = "TASK_EXECUTION_ROLE"
          value = var.var_ecstaskservice_rolearn
        }
        environment_variable {
            name = "GHOST_DATABASE_PASSWORD"
            # type = "PARAMETER_STORE"
            value = var.var_ssm_database_password
        }
        environment_variable {
            name = "GHOST_ASSET_S3_BUCKET"
            value = var.var_s3_content_assets_name
        }
        environment_variable {
            name = "GHOST_DATABASE_USER"
            # type = "PARAMETER_STORE"
            value = var.var_ssm_database_username
        }
        environment_variable {
            name = "GHOST_DATABASE_NAME"
            value = var.var_database_name
        }
        environment_variable {
            name = "GHOST_AWS_ACCESS_KEY_ID"
            value = var.var_ghost_content_user_access_key
        }
        environment_variable {
            name = "GHOST_AWS_SECRET_ACCESS_KEY_ID"
            value = var.var_ghost_content_user_secret_access_key
        }
        environment_variable {
            name = "GHOST_FAMILY"
            value = var.var_td_family
        }
        environment_variable {
          name = "GHOST_DATABASE_HOST"
          value = var.var_database_writer_endpoint
        }
        environment_variable {
            name = "ENV"
            value = var.env
        }
        environment_variable {
          name = "TASK_DEFINITION_ARN"
          value = var.var_ecs_task_definition_arn
        }
        environment_variable {
          name = "TASK_DEFINITION_REVISION"
          value = var.var_ecs_task_definition_revision
        }
        environment_variable {
          name = "GHOST_URL"
          value = var.var_hostnames
        }
    }
    source {
        type      = "CODEPIPELINE"
        buildspec = "buildspec.yaml"
    }
    cache {
        type  = "LOCAL"
        modes = ["LOCAL_DOCKER_LAYER_CACHE"]
    }
}