
resource "aws_ecs_cluster" "ghost_ecs_cluster" {
  name = "ghost-${var.env}-cluster"
}

resource "aws_ecs_task_definition" "ghost_td" {
  family = var.var_family
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 512
  memory = 1024
  execution_role_arn = var.var_ecstaskservice_rolearn
  task_role_arn = var.var_ecstaskservice_rolearn
  # container_definitions = jsondecode(file("taskdef.json")

  container_definitions = jsonencode(
 [
    {
      "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/ghost",
          "awslogs-region": "${var.var_region}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "hostPort": 2368,
          "protocol": "tcp",
          "containerPort": 2368
        }
      ],
      "cpu": 512,
      "memory": 1024
      "image": "${var.var_ecr_url}:latest"
      "name": "${var.var_container_name}"
      "networkMode": "awsvpc"
      "environment": [
        {
          "name": "AWS_DEFAULT_REGION",
          "value": "${var.var_region}"
        },
        {
          "name": "AWS_SECRET_ACCESS_KEY",
          "value": "${var.var_ghost_content_user_secret_access_key}"
        },
        {
          "name": "database__client",
          "value": "mysql"
        },
        {
          "name": "database__connection__database",
          "value": "ghost"
        },
        {
          "name": "database__connection__host",
          "value": "${var.var_cluster_identifier}"
        },
        {
          "name": "database__connection__password",
          "value": "${var.var_ssm_database_password}"
        },
        {
          "name": "database__connection__user",
          "value": "${var.var_ssm_database_username}"
        },
        {
          "name": "GHOST_STORAGE_ADAPTER_S3_PATH_BUCKET",
          "value": "${var.var_s3_content_assets_arn}"
        },
        {
          "name": "storage__active",
          "value": "s3"
        },
        {
          "name": "storage__s3__bucket",
          "value": "${var.var_s3_content_assets_arn}"
        },
        {
          "name": "storage__s3__region",
          "value": "${var.var_region}"
        },
        {
          "name": "url",
          "value": "http://${var.var_hostnames}"
        },
        {
          "name": "GHOST_STORAGE_ADAPTER_S3_SSE",
          "value": "AES256"
        },
        {
          "name": "GHOST_STORAGE_ADAPTER_S3_SIGNATURE_VERSION",
          "value": "v4"
        }
      ]
    }
  ]
)

lifecycle {
    ignore_changes = [container_definitions]
  }

}

resource "aws_ecs_service" "ghost_ecs_svc" {
  name = "ghost-svc"
  cluster = aws_ecs_cluster.ghost_ecs_cluster.id
  task_definition = aws_ecs_task_definition.ghost_td.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [var.var_fargate_sg_id]
    subnets = var.var_nl_privatesubnet
    assign_public_ip = false
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = var.var_alb_tg_arn
    container_name = var.var_container_name
    container_port = 2368
  }

  lifecycle {
    ignore_changes = [launch_type,platform_version,task_definition,load_balancer,deployment_controller,desired_count]
  }

}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ghost_ecs_cluster.name}/${aws_ecs_service.ghost_ecs_svc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "target-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  target_tracking_scaling_policy_configuration {
  target_value = 70
    customized_metric_specification {
      metric_name = "CPUUtilization"
      namespace   = aws_appautoscaling_target.ecs_target.service_namespace
      statistic   = "Average"
      unit        = "Percent"
    }
  }
}