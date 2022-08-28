# --- lb/outputs.tf


output "elb" {
  value = aws_lb.ttp_lb.id
}

output "alb_tg" {
  value = aws_lb_target_group.ttp_tg.arn
}

output "alb_dns" {
  value = aws_lb.ttp_lb.dns_name
}