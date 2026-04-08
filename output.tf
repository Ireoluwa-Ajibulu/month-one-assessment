output "vpc_id" {
  description = "TechCorp VPC ID"
  value       = aws_vpc.techcorp_vpc.id
}

output "load_balancer_dns" {
  description = "Load Balancer DNS Name"
  value       = aws_lb.techcorp_alb.dns_name
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP"
  value       = aws_eip.bastion_eip.public_ip
}