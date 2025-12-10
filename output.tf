output "aws_instance_id" {
  description = "The ID of the AWS EC2 instance"
  value       = aws_instance.test_instance.id
}

output "aws_instance_public_ip" {
  description = "The public IP address of the AWS EC2 instance"
  value       = aws_instance.test_instance.public_ip
}

output "aws_instance_name" {
  description = "The Name tag of the AWS EC2 instance"
  value       = aws_instance.test_instance.tags["Name"]
}

output "aws_az" {
  description = "The availability zone of the AWS EC2 instance"
  value       = aws_instance.test_instance.availability_zone
}