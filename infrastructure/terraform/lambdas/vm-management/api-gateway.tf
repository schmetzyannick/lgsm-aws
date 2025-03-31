resource "aws_api_gateway_rest_api" "api" {
  name        = "vm-management-api"
  description = "API for VM Management"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeploy = "${timestamp()}"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.start_vm_integration,
    aws_api_gateway_integration.stop_vm_integration,
    aws_api_gateway_integration.all-vms-resource-integration,
    aws_api_gateway_integration_response.all-vms-resource-integration_response,
    aws_api_gateway_integration.mgmt_integration,                   # Added for /mgmt route
    aws_api_gateway_integration_response.mgmt_integration_response, # Added for /mgmt route
    aws_api_gateway_method_response.mgmt_method_response            # Added for /mgmt route
  ]
}

resource "aws_api_gateway_stage" "prod_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.deployment.id

  variables = {
    lambdaAlias = "prod"
  }
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "vm-management-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.prod_stage.stage_name
  }

  throttle_settings {
    rate_limit  = 10 # Maximum number of requests per second
    burst_limit = 20 # Maximum number of requests in a burst
  }

  quota_settings {
    limit  = 5000    # Maximum number of requests allowed
    period = "MONTH" # Time period for the quota (e.g., DAY, WEEK, MONTH)
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name    = "vm-management-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.vm_management.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

data "aws_route53_zone" "hosted-zone" {
  name = var.zone-name
}

resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name              =  "${local.api-url-name}.${data.aws_route53_zone.hosted-zone.name}"
  regional_certificate_arn = aws_acm_certificate.api_gateway_cert.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_acm_certificate" "api_gateway_cert" {
  domain_name       = "${local.api-url-name}.${data.aws_route53_zone.hosted-zone.name}"
  validation_method = "DNS"

  tags = {
    Name = "API Gateway Certificate"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_gateway_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.hosted-zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

resource "aws_api_gateway_base_path_mapping" "custom_domain_mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  domain_name = aws_api_gateway_domain_name.custom_domain.domain_name
  stage_name  = aws_api_gateway_stage.prod_stage.stage_name
}

resource "aws_route53_record" "api_gateway_dns" {
  zone_id = data.aws_route53_zone.hosted-zone.zone_id
  name    = local.api-url-name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.custom_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.regional_zone_id
    evaluate_target_health = false
  }
}

output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.region}.amazonaws.com/prod/vm"
}


