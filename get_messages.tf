#Terraform configuration for the get messages endpoint

resource "aws_apigatewayv2_integration" "api_get_messages" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda-get-messages.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_get_messages_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /get_messages"
  target    = "integrations/${aws_apigatewayv2_integration.api_get_messages.id}"
}

resource "aws_lambda_permission" "api_gw_get_messages" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-get-messages.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
