#Terraform configuration for the create account endpoint

resource "aws_apigatewayv2_integration" "api_create_account" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda-create-account.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_create_account_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /create_account"
  target    = "integrations/${aws_apigatewayv2_integration.api_create_account.id}"
}

resource "aws_lambda_permission" "api_gw_create_account" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-create-account.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
