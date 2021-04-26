output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "aws_cognito_user_pool" {
  value = aws_cognito_user_pool.cognito.id
}
