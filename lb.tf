resource "aws_lb" "kodehauz_lb" {
  name               = "kodehauz-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.kodehauz_lb_sg.id]
  subnets            = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  depends_on = [aws_autoscaling_group.kodehauz_asg]
}


resource "aws_lb_target_group" "kodehauz_tg" {
  name     = "kodehauz-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kodehauz_vpc.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "kodehauz_lb_listener" {
  load_balancer_arn = aws_lb.kodehauz_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kodehauz_tg.arn
  }
}