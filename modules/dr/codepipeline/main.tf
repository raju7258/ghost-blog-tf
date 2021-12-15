resource "aws_codepipeline" "codepipeline" {
  name = "ghost-${var.env}"
  role_arn = var.var_codepipeline_rolearn

  artifact_store {
    location = var.var_s3_codepipeline_artifacts
    type = "S3"
  }

  stage {
    name = "Source"
    action {
      name = "Source"
          category = "Source"
          owner = "AWS"
          provider = "CodeStarSourceConnection"
          version = "1"
          output_artifacts = ["SourceOutput"]
          configuration = {
              FullRepositoryId = var.repoid
              BranchName   = var.var_branchname
              ConnectionArn = var.var_codestar_arn
              OutputArtifactFormat = "CODE_ZIP"
          }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["ImageArtifact","DefinitionArtifact"]
      run_order        = 1
      configuration = {
        ProjectName = var.var_codebuild_id
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeDeployToECS"
      # input_artifacts  = ["BuildOutput"]
      input_artifacts = ["ImageArtifact","DefinitionArtifact"]
      run_order        = 1
      configuration = {
        ApplicationName                = var.var_codedeploy_appname
        DeploymentGroupName            = var.var_codedeploy_groupname
        TaskDefinitionTemplateArtifact = "DefinitionArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
        AppSpecTemplateArtifact        = "DefinitionArtifact"
        AppSpecTemplatePath            = "appspec.yaml"
        Image1ArtifactName             = "ImageArtifact"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }

}

