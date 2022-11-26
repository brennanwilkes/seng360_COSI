resource "aws_iam_role" "lambda-login-lambda-iam-role" {
  name               = "lambda-login-lambda-iam-role"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

resource "aws_lambda_function" "lambda-login" {
  function_name    = "lambda-login"
  role             = aws_iam_role.lambda-login-lambda-iam-role.arn
  filename         = "outputs/login.py.zip"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda-login-archive.output_base64sha256
  handler          = "login.lambda_handler"
  vpc_config {
    subnet_ids         = [aws_subnet.devxp_vpc_subnet_public0.id]
    security_group_ids = [aws_security_group.devxp_security_group.id]
  }
}

resource "aws_iam_policy" "lambda-login-vpc-policy" {
  name   = "lambda-login_vpc_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda-login-vpc-policy-document.json
}

resource "aws_iam_role_policy_attachment" "lambda-login-vpc-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-login-vpc-policy.arn
  role       = aws_iam_role.lambda-login-lambda-iam-role.name
}

data "archive_file" "lambda-login-archive" {
  type        = "zip"
  source_dir  = "lambda/"
  excludes    = setsubtract(fileset("lambda/", "*"), ["login.py", "common.py"])
  output_path = "outputs/login.py.zip"
}

data "aws_iam_policy_document" "lambda-login-vpc-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "api_login" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda-login.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_login_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /login"
  target    = "integrations/${aws_apigatewayv2_integration.api_login.id}"
}

resource "aws_lambda_permission" "api_gw_login" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-login.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
