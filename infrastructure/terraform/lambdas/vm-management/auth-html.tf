resource "aws_api_gateway_resource" "mgmt_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "mgmt"
}

resource "aws_api_gateway_method" "mgmt_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.mgmt_resource.id
  http_method   = "GET"
  authorization = "NONE" # No authentication required
}

resource "aws_api_gateway_integration" "mgmt_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.mgmt_resource.id
  http_method = aws_api_gateway_method.mgmt_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "mgmt_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.mgmt_resource.id
  http_method = aws_api_gateway_method.mgmt_method.http_method
  status_code = "200"

  response_templates = {
    "text/html" = file("${path.module}/../../../../html/vm-managemant-api.html")
  }

  content_handling = "CONVERT_TO_TEXT"

  depends_on = [aws_api_gateway_integration.mgmt_integration]
}

resource "aws_api_gateway_method_response" "mgmt_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.mgmt_resource.id
  http_method = aws_api_gateway_method.mgmt_method.http_method
  status_code = "200"

  response_models = {
    "text/html" = "Empty"
  }

  depends_on = [aws_api_gateway_integration.mgmt_integration]
}