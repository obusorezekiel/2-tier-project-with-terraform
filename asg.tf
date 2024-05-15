resource "aws_launch_template" "kodehauz_bastion_lt" {
  name                   = "kodehauz-bastion"
  instance_type          = "t2.micro"
  image_id               = "ami-0e001c9271cf7f3b9"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = "ec2-key"

  tags = {
    Name = "kodehauz_bastion"
  }
}

resource "aws_autoscaling_group" "kodehauz_bastion_asg" {
  name                = "three_tier_bastion"
  vpc_zone_identifier = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.kodehauz_bastion_lt.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "kodehauz_app_lt" {
  name                   = "kodehauz-lt"
  instance_type          = "t2.micro"
  image_id               = "ami-0e001c9271cf7f3b9"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = filebase64("install-apache.sh")
  key_name               = "ec2-key"

  tags = {
    Name = "kodehauz_app"
  }
}

resource "aws_autoscaling_group" "kodehauz_asg" {
  name                = "kodehauz_asg"
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [aws_lb_target_group.kodehauz_tg.arn]

  launch_template {
    id      = aws_launch_template.kodehauz_app_lt.id
    version = "$Latest"
  }
}



