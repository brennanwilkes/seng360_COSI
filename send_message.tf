#Terraform configuration for the send message endpoint

resource "aws_apigatewayv2_integration" "api_send_message" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda-send-message.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_send_message_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /send_message"
  target    = "integrations/${aws_apigatewayv2_integration.api_send_message.id}"
}

resource "aws_lambda_permission" "api_gw_send_message" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-send-message.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
