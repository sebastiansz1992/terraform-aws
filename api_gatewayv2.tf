# API Gateway
resource "aws_apigatewayv2_api" "agw" {
  name          = "api_gateway"
  protocol_type = "HTTP"
  description   = "Descripción del api gateway"
  tags          = module.config.tags["apigateway"]
}

resource "aws_apigatewayv2_deployment" "apigw_deployment" {
  count      = 1
  api_id     = aws_apigatewayv2_api.agw.id
  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_apigatewayv2_integration.nombre_lambda_uno),
      jsonencode(aws_apigatewayv2_route.route_nombre_lambda_uno),
      jsonencode(aws_apigatewayv2_integration.nombre_lambda_dos),
      jsonencode(aws_apigatewayv2_route.route_nombre_lambda_dos),
    )))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  count                = 1
  api_id               = aws_apigatewayv2_api.agw.id
  auto_deploy          = var.stage_autodeploy
  name                 = var.stage
}

resource "aws_apigatewayv2_route" "route_nombre_lambda_uno" {
  api_id    = aws_apigatewayv2_api.agw.id
  route_key = "ANY /nombre_del_path_uno"
  target = "integrations/${aws_apigatewayv2_integration.nombre_lambda_uno.id}"
}

resource "aws_apigatewayv2_route" "route_nombre_lambda_dos" {
  api_id    = aws_apigatewayv2_api.agw.id
  route_key = "ANY /nombre_del_path_dos"
  target = "integrations/${aws_apigatewayv2_integration.nombre_lambda_dos.id}"
}

resource "aws_apigatewayv2_integration" "nombre_lambda_uno" {
  api_id                    = aws_apigatewayv2_api.agw.id
  integration_type          = "AWS_PROXY"
  integration_method        = "POST"
  integration_uri           =  "ARN de la lambda"
}

resource "aws_apigatewayv2_integration" "nombre_lambda_dos" {
  api_id                    = aws_apigatewayv2_api.agw.id
  integration_type          = "AWS_PROXY"
  integration_method        = "POST"
  integration_uri           = "ARN de la lambda"
}