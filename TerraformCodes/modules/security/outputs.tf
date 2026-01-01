output "security_group1_id" {
  value = aws_security_group.ecs_tasks_sg.id
}

output "security_group2_id" {
  value = aws_security_group.ecs_alb_sg.id
}