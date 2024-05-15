
output "alb_dns" {
  value = aws_lb.kodehauz_lb.dns_name
}

output "lb_endpoint" {
  value = aws_lb.kodehauz_lb.dns_name
}

output "lb_tg_name" {
  value = aws_lb_target_group.kodehauz_tg.name
}

output "lb_tg" {
  value = aws_lb_target_group.kodehauz_tg.arn
}

output "vpc_id" {
  value = aws_vpc.kodehauz_vpc.id
}