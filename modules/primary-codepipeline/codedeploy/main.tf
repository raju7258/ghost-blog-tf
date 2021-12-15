resource "aws_codedeploy_app" "ghost-code-deploy" {
  compute_platform = "ECS"
  name = "ghost-${var.env}-codedeploy"
}

locals {
  deployment_group_name = "ghost-${var.env}-code-dpg"
}

resource "aws_codedeploy_deployment_group" "ghost-code-dpg" {
  app_name = aws_codedeploy_app.ghost-code-deploy.name
  deployment_group_name = local.deployment_group_name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn = var.var_codedeploy_rolearn

  blue_green_deployment_config {
    deployment_ready_option {
        action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 2
    }
  }

  ecs_service {
    cluster_name = var.var_ecs_cluster_name
    service_name = var.var_ecs_service_name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
      target_group_pair_info {
        prod_traffic_route {
            listener_arns = [var.var_alb_listener_arn]
        }
        target_group {
            name = var.var_alb_tg_name
        }
        target_group {
            name = var.var_alb_tg2_name
        }
      }
  }
}

