output "out_rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "out_alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "out_fargate_sg_id" {
  value = aws_security_group.fargate_sg.id
}