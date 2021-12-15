output "out_albdns" {
    value = aws_lb.alb.dns_name
}
output "out_albarn" {
    value = aws_lb.alb.arn
}

output "out_alb_tg_arn" {
  value = aws_lb_target_group.target["tg1"].id
}

output "out_alb_tg_name" {
  value = aws_lb_target_group.target["tg1"].name
}

output "out_alb_tg2_id" {
  value = aws_lb_target_group.target["tg2"].id
}

output "out_alb_tg2_name" {
  value = aws_lb_target_group.target["tg2"].name
}

output "out_alb_listener_arn" {
  value = aws_lb_listener.listener2.arn
}