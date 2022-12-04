#Terraform configuration for the get users endpoint

resource "aws_iam_role" "lambda-get-users-lambda-iam-role" {
  name               = "lambda-get-users-lambda-iam-role"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

resource "aws_lambda_function" "lambda-get-users" {
  function_name    = "lambda-get-users"
  role             = aws_iam_role.lambda-get-users-lambda-iam-role.arn
  filename         = "outputs/get_users.py.zip"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda-get-users-archive.output_base64sha256
  handler          = "get_users.lambda_handler"
  vpc_config {
    subnet_ids         = [aws_subnet.devxp_vpc_subnet_public0.id]
    security_group_ids = [aws_security_group.devxp_security_group.id]
  }
}

resource "aws_iam_policy" "lambda-get-users-vpc-policy" {
  name   = "lambda-get-users_vpc_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda-get-users-vpc-policy-document.json
}

resource "aws_iam_role_policy_attachment" "lambda-get-users-vpc-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-get-users-vpc-policy.arn
  role       = aws_iam_role.lambda-get-users-lambda-iam-role.name
}


data "archive_file" "lambda-get-users-archive" {
  type        = "zip"
  source_dir  = "lambda/"
  excludes    = setsubtract(fileset("lambda/", "*"), ["get_users.py", "common.py"])
  output_path = "outputs/get_users.py.zip"
}

data "aws_iam_policy_document" "lambda-get-users-vpc-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "api_get_users" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.lambda-get-users.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "api_get_users_route" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /users"
  target    = "integrations/${aws_apigatewayv2_integration.api_get_users.id}"
}

resource "aws_lambda_permission" "api_gw_get_users" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-get-users.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
