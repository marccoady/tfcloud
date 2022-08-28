# -- as/outputs.tf

output "db_sg" {
  value = aws_autoscaling_group.asg_webserver
}
