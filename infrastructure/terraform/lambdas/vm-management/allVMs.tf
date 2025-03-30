resource "aws_api_gateway_resource" "all-vms-resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "allVMs"
}

resource "aws_api_gateway_method" "all-vms-resource-method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.all-vms-resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_method_response" "all-vms-resource-method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.all-vms-resource.id
  http_method = aws_api_gateway_method.all-vms-resource-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "all-vms-resource-integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.all-vms-resource.id
  http_method             = aws_api_gateway_method.all-vms-resource-method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.vm_management.invoke_arn

  request_templates = {
    "application/json" = jsonencode({
      body       = jsonencode({
        action = "getHTML"
      })
    })
  }
}

resource "aws_api_gateway_integration_response" "all-vms-resource-integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.all-vms-resource.id
  http_method = aws_api_gateway_method.all-vms-resource-method.http_method
  status_code = "200"
}