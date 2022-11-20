resource "aws_apigatewayv2_integration" "api_delete_account" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda-delete-account.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_delete_account_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /delete_account"
  target    = "integrations/${aws_apigatewayv2_integration.api_delete_account.id}"
}

resource "aws_lambda_permission" "api_gw_delete_account" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-delete-account.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
