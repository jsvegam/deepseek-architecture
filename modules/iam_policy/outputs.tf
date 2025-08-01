output "arn" {
  description = "ARN de la política IAM creada"
  value       = aws_iam_policy.this.arn
}
