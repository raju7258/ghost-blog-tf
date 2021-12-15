variable "iamroles" {
  type = map
  default = {
    role1 = {
      rolename = "ECS-Codepipeline-Role"
      service = "codepipeline.amazonaws.com"
    },
    role2 = {
      rolename = "ECS-Codebuild-Role"
      service = "codebuild.amazonaws.com"
    },
    role3 = {
      rolename = "ECS-task-service-Role"
      service = "ecs-tasks.amazonaws.com"
    },
    role4 = {
      rolename = "ECS-Codedeploy-Role"
      service = "codedeploy.amazonaws.com"
    },
    role5 = {
      rolename = "S3-replication-role"
      service = "s3.amazonaws.com"
    },
    role6 = {
      rolename = "lambdarole"
      service = "lambda.amazonaws.com"
    }   
    
  }
}

