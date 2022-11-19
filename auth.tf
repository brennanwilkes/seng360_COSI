resource "aws_iam_role_policy_attachment" "lambda-send-message-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-send-message-lambda-iam-role.name
}
resource "aws_iam_role_policy_attachment" "lambda-create-account-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-create-account-lambda-iam-role.name
}
resource "aws_iam_role_policy_attachment" "lambda-get-messages-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-get-messages-lambda-iam-role.name
}
resource "aws_iam_role_policy_attachment" "lambda-delete-account-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-delete-account-lambda-iam-role.name
}


resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.devxp_vpc.id
  service_name = "com.amazonaws.us-west-2.dynamodb"
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  route_table_id  = aws_route_table.devxp_vpc_routetable_pub.id
}
