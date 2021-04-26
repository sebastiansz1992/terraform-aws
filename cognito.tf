provider "aws" {
    region = "us-east-1"
    access_key = "XXXXXXXXXXXXXXXXXXXXXXXXX"
    secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
}

resource "aws_cognito_user_pool" "cognito" {
  name = "tesgroupfromterraform"
  username_attributes = [ "email" ]
  auto_verified_attributes = [ "email" ]
  schema {
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable                  = false
    name = "email"
    required = true
    string_attribute_constraints {
      min_length = 6
      max_length = 60
    }
  }
  password_policy  {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }
  }
  lifecycle {
    ignore_changes = [
      schema     ### AWS doesn't allow schema updates, so every build will re-create the user pool unless we ignore this bit
    ]
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "tesgroupfromterraformclient"
  user_pool_id = aws_cognito_user_pool.cognito.id
  generate_secret     = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "login-parametrizador-terraform"
  user_pool_id = aws_cognito_user_pool.cognito.id
}