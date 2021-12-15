resource "aws_lb" "alb" {
  name               = "alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.var_alb_sg}"]
  subnets            = var.var_public_subnets

  enable_deletion_protection = false
#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     enabled = true
#   }
  tags = {
    Environment       = "${var.env}"
}
}

resource "aws_lb_target_group" "target" {
  for_each    = var.targetgroups
  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  target_type = "ip"
  vpc_id      = var.var_vpcid
}

resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [
    aws_lb.alb
  ]
}

resource "aws_lb_listener" "listener2" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.var_acm_pri_alb

  default_action {
    type             = "fixed-response"
    fixed_response {
    content_type     = "text/plain"
    status_code      = 500
  }
}
depends_on = [
    aws_lb.alb
  ]
}

resource "aws_lb_listener_rule" "listener3" {
  listener_arn = aws_lb_listener.listener2.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target["tg1"].arn
  }
  condition {
    host_header {
      values = [var.var_hostnames]
    }
  }
  lifecycle {
    ignore_changes = [action,listener_arn,condition]
  }
  depends_on = [
    aws_lb.alb,
    aws_lb_target_group.target
  ]
}

# resource "aws_lb_target_group_attachment" "target_attachment" {
#   target_group_arn = aws_lb_target_group.target.arn
#   target_id = var.var_ecs_server_id
#   port = 2368
# }