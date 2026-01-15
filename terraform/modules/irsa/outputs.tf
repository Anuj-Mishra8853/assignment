output "role_arn" {
  description = "IRSA role ARN"
  value       = aws_iam_role.irsa.arn
}
