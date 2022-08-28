# --- lb/main.tf

resource "aws_lb" "ttp_lb" {
  name               = "ttp-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.web_sg]
  subnets            = tolist(var.pb_sn)

}

resource "aws_lb_target_group" "ttp_tg" {
  name     = "ttp-lb-tg-${substr(uuid(), 0, 3)}"
  protocol = var.tg_protocol
  port     = var.tg_port
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_listener" "ttp_lb_listener" {
  load_balancer_arn = aws_lb.ttp_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ttp_tg.arn
  }
}