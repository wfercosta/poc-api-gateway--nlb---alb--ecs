resource "aws_api_gateway_vpc_link" "this" {
  name        = "${local.prefix}-nlb-vpclink"
  description = "Connectivity to  NLBs"
  target_arns = [aws_lb.nlb.arn]
}

resource "aws_api_gateway_rest_api" "this" {

  name = "${local.prefix}-api-gateway"

  body = jsonencode(yamldecode(templatefile("_templates/openapi.tfpl", {
    prefix      = local.prefix
    nlb_dns     = aws_lb.nlb.dns_name
    vpc_link_id = aws_api_gateway_vpc_link.this.id
  })))

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "dev"
}

