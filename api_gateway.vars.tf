variable "api_gateway_component_id" {
    type    = string
    default = "api-gateway"
}

variable "aws_api_gateway_integration_base_uri" {
    type    = string
    default = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/"
}

variable "stage" {
  type    = string
  default = "endpoint"
}