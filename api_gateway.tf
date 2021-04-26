# API Gateway
resource "aws_api_gateway_rest_api" "agw" {
  name = "api_gateway"
  description   = "Descripción del api gateway"
}

resource "aws_api_gateway_deployment" "apigw_deployment" {
  count       = 1
  rest_api_id = aws_api_gateway_rest_api.agw.id
  variables = {
    trigger_hash = sha1(join(",", [
      jsonencode(aws_api_gateway_resource.resource),
      jsonencode(aws_api_gateway_integration.integration),
      jsonencode(aws_api_gateway_method.method),
      jsonencode(aws_api_gateway_resource.resource_example_1),
      jsonencode(aws_api_gateway_integration.integration_example_1),
      jsonencode(aws_api_gateway_method.method_example_1)
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  count                = 1
  rest_api_id          = aws_api_gateway_rest_api.agw.id
  deployment_id        = aws_api_gateway_deployment.apigw_deployment.0.id
  stage_name           = var.stage
  xray_tracing_enabled = false
}

# APGW Calcula Provision
resource "aws_api_gateway_resource" "resource" {
  path_part   = "lamba_example_0"
  parent_id   = aws_api_gateway_rest_api.agw.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.agw.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.agw.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.agw.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST" // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration
  type                    = "AWS"
  uri                     = "${var.aws_api_gateway_integration_base_uri}${arn_lambda}/invocations"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "Nombre de la funcion que retorna la lambda"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.agw.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

# APGW Calcula Utilidad
resource "aws_api_gateway_resource" "resource_example_1" {
  path_part   = "lambda_example_1"
  parent_id   = aws_api_gateway_rest_api.agw.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.agw.id
}

resource "aws_api_gateway_method" "method_example_1" {
  rest_api_id   = aws_api_gateway_rest_api.agw.id
  resource_id   = aws_api_gateway_resource.resource_example_1.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration_example_1" {
  rest_api_id             = aws_api_gateway_rest_api.agw.id
  resource_id             = aws_api_gateway_resource.resource_example_1.id
  http_method             = aws_api_gateway_method.method_example_1.http_method
  integration_http_method = "POST" // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration
  type                    = "AWS"
  uri                     = "${var.aws_api_gateway_integration_base_uri}${arn_lambda}/invocations"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda_example_1" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "Nombre de la funcion que retorna la lambda"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.agw.id}/*/${aws_api_gateway_method.method_example_1.http_method}${aws_api_gateway_resource.resource_example_1.path}"
}
