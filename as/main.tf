# --- as/main.tf

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


}

resource "aws_launch_template" "bastion_host" {
  name_prefix            = "bastion_host"
  image_id               = data.aws_ami.server_ami.id
  instance_type          = var.bastion_type
  vpc_security_group_ids = [var.pb_sg]
  key_name               = var.key

  tags = {
    Name = "bastion_host"
  }
}

resource "aws_autoscaling_group" "asg_bastion" {
  name                = "asg_bastion"
  vpc_zone_identifier = tolist(var.pb_sn)
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.bastion_host.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "asg_webserver" {
  name_prefix            = "webserver"
  image_id               = data.aws_ami.server_ami.id
  instance_type          = var.webserver_type
  vpc_security_group_ids = [var.pt_sg]
  key_name               = var.key
  user_data              = filebase64("user_data.sh")

  tags = {
    Name = "webserver"
  }
}

resource "aws_autoscaling_group" "asg_webserver" {
  name                = "asg_webserver"
  vpc_zone_identifier = tolist(var.pb_sn)
  min_size            = 3
  max_size            = 5
  desired_capacity    = 3

  launch_template {
    id      = aws_launch_template.asg_webserver.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg_webserver.id
  lb_target_group_arn = var.alb_tg
}