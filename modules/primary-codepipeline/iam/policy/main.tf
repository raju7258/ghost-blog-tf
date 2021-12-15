
data aws_caller_identity "current" {}

# CodePipeline Policy

data "aws_iam_policy_document" "codepipeline-policy" {
    statement{
        sid = ""
        #actions = ["cloudwatch:*", "s3:*", "codedeploy:*", "codebuild:*","codestar-connections:UseConnection","ecs:*","iam:*","sns:*"]
        actions = ["s3:*","codestar-connections:UseConnection", "codebuild:startBuild","codebuild:BatchGetBuilds","codedeploy:GetApplication","ecs:RegisterTaskDefinition","iam:PassRole","codedeploy:GetApplicationRevision","codedeploy:CreateDeployment","codedeploy:GetDeploymentConfig","codedeploy:RegisterApplicationRevision","codedeploy:GetDeployment"]
        resources = ["${var.var_codestar_arn}","${var.var_s3_codepipeline_artifacts_arn}/*", "${var.var_codebuild_arn}","${var.var_codedeploy_app_arn}","*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "codepipeline-policy" {
    name = "${var.env}-Codepipeline-Policy"
    path = "/"
    description = "Codepipeline Policy for ${var.env}"
    policy = data.aws_iam_policy_document.codepipeline-policy.json
}

resource "aws_iam_role_policy_attachment" "codepipeline-policy-attachment" {
    policy_arn = aws_iam_policy.codepipeline-policy.arn
    role = var.var_codepipeline_rolename
}

# CodeBuild Role

data "aws_iam_policy_document" "codebuild-policy" {
    statement{
        sid = ""
        actions = ["s3:*", "codebuild:*", "ecr:TagResource","ecr:PutImage", "ecr:StartImageScan", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents","ec2:CreateNetworkInterface","ec2:DescribeDhcpOptions","ec2:DescribeNetworkInterfaces","ec2:DeleteNetworkInterface","ec2:DescribeSubnets","ec2:DescribeSecurityGroups","ec2:DescribeVpcs","ec2:CreateNetworkInterfacePermission","ecr:GetAuthorizationToken","ecr:InitiateLayerUpload","ecr:UploadLayerPart","ecr:CompleteLayerUpload","ecr:BatchCheckLayerAvailability","ssm:GetParameters"]
        resources = ["${var.var_s3_codepipeline_artifacts_arn}/*", "${var.var_codebuild_arn}","arn:aws:logs:${var.var_region}:${data.aws_caller_identity.current.account_id}:log-group:*", "arn:aws:logs:${var.var_region}:${data.aws_caller_identity.current.account_id}:*:log-stream:*", "${var.var_ecr_arn}","arn:aws:ec2:${var.var_region}:${data.aws_caller_identity.current.account_id}:network-interface/*","*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "codebuild-policy" {
    name = "ECS-Codebuild-policy"
    path = "/"
    description = "CodeBuild Policy for ${var.env}"
    policy = data.aws_iam_policy_document.codebuild-policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild-policy-attachment" {
    policy_arn  = aws_iam_policy.codebuild-policy.arn
    role        = var.var_codebuild_rolename
}

# IAM User Policy

data "aws_iam_policy_document" "iam-content-policy" {
    statement{
        sid = ""
        actions = ["s3:*"]
        resources = ["${var.var_s3_content_assets_arn}/*","${var.var_s3_content_assets_arn}/*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "iam-content-policy" {
    name = "iam-${var.env}-content-policy"
    path = "/"
    description = "IAM Policy for ${var.env} content/assets"
    policy = data.aws_iam_policy_document.iam-content-policy.json

}

resource "aws_iam_policy_attachment" "iam-content-policy-attachment" {
    name        = "iam-content-user-${var.env}-policy"
    policy_arn  = aws_iam_policy.iam-content-policy.arn
    users       = [var.var_ghost_content_user_name]
}

#EC2 Task Definition Role
data "aws_iam_policy_document" "tasks-service-role-policy" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codedeploy:*","iam:*", "ecs:*","ssm:GetParameters","rds-db:*","kms:*","ecr:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "tasks-service-role-policy" {
    name = "ECS-Task-Role-Policy"
    path = "/"
    description = "ECS Task Execution Policy for ${var.env}"
    policy = data.aws_iam_policy_document.tasks-service-role-policy.json
}

resource "aws_iam_role_policy_attachment" "tasks-service-role-attachment" {
  role       = var.var_ecstaskservice_rolename
  policy_arn = aws_iam_policy.tasks-service-role-policy.arn
}


#CodeDeploy Role

data "aws_iam_policy_document" "codedeploy-policy" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codedeploy:*","iam:PassRole", "ecs:*"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_iam_policy" "codedeploy-policy" {
    name = "ghost-${var.env}-cicd-deploy-policy"
    path = "/"
    description = "Codedeploy policy"
    policy = data.aws_iam_policy_document.codedeploy-policy.json
}
resource "aws_iam_role_policy_attachment" "codedeploy-policy-attachment1" {
    policy_arn  = aws_iam_policy.codedeploy-policy.arn
    role        = var.var_codedeploy_rolename
}
resource "aws_iam_role_policy_attachment" "codedeploy-policy-attachment2" {
    policy_arn  = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
    role        = var.var_codedeploy_rolename
}


#S3 Replication Policy

data "aws_iam_policy_document" "s3-replication-policy" {
    statement{
        sid = ""
        actions = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
        resources = ["${var.var_s3_content_assets_arn}"]
        effect = "Allow"
    }   
    statement{
        sid = ""
        actions = ["s3:GetObjectVersionForReplication", "s3:GetObjectVersionAcl", "s3:GetObjectVersionTagging"]
        resources = ["${var.var_s3_content_assets_arn}/*"]
        effect = "Allow"
    }
    statement {
        sid = ""
        actions = ["s3:ReplicateObject", "s3:ReplicateDelete",  "s3:ReplicateTags"]
        resources = ["${var.var_s3_content_assets_arn_destination}/*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "s3-replication-policy" {
    name = "ghost-${var.env}-s3-replication-policy"
    path = "/"
    description = "S3 Replication Policy"
    policy = data.aws_iam_policy_document.s3-replication-policy.json
}

resource "aws_iam_role_policy_attachment" "s3-replication-policy-attachment" {
    policy_arn  = aws_iam_policy.s3-replication-policy.arn
    role        = var.var_s3replicationrolename
}

# Lambda Role Policy
data "aws_iam_policy_document" "data-lambda-policy" {
    statement {
        actions = ["logs:CreateLogGroup" ]
        resources = ["arn:aws:logs:${var.var_region}:${data.aws_caller_identity.current.account_id}:*"]
        effect = "Allow"
    }
    statement {
        actions = ["logs:CreateLogStream", "logs:PutLogEvents" ]
        resources = ["arn:aws:logs:${var.var_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*:*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "lambda-policy" {
    name = "ghost-${var.env}-lambda-policy"
    path = "/"
    description = "Lambda Policy"
    policy = data.aws_iam_policy_document.data-lambda-policy.json
}

resource "aws_iam_role_policy_attachment" "lambda-policy-attachment" {
    policy_arn  = aws_iam_policy.lambda-policy.arn
    role        = var.var_lambdarolename
}