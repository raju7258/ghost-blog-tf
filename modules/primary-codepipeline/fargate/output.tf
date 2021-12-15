output "out_ecs_service_id" {
  value = aws_ecs_service.ghost_ecs_svc.id
}

output "out_ecs_cluster_name" {
    value = aws_ecs_cluster.ghost_ecs_cluster.name
}

output "out_ecs_service_name" {
    value = aws_ecs_service.ghost_ecs_svc.name
}

output "out_ecs_server_id" {
  value = aws_ecs_service.ghost_ecs_svc.id
}

output "out_ecs_container_name" {
  value = var.var_container_name
}

output "out_td_family" {
  value = var.var_family
}

output "out_ecs_task_definition_arn" {
  value = aws_ecs_task_definition.ghost_td.arn
}

output "out_ecs_task_definition_revision" {
  value = aws_ecs_task_definition.ghost_td.revision
}

# output "out_ecs_container_name" {
#   value = 
# }