output "alb_name" {
  value       = aws_lb.ecs_alb.name
}

output "alb_arn" {
  value       = aws_lb.ecs_alb.arn
}

output "alb_dns_name" {
  value       = aws_lb.ecs_alb.dns_name
}

output "alb_zone_id" {
  value       = aws_lb.ecs_alb.zone_id
}

output "user_target_group_arn" {
  value       = aws_lb_target_group.user_tg.arn
}

output "product_target_group_arn" {
  value       = aws_lb_target_group.product_tg.arn
}

output "http_listener_arn" {
  value       = aws_lb_listener.http_listener.arn
}
