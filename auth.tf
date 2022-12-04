#Terraform configuration for IAM

#Allow the send message endpoint to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda-send-message-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-send-message-lambda-iam-role.name
}

#Allow the create account endpoint to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda-create-account-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-create-account-lambda-iam-role.name
}

#Allow the get messages endpoint to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda-get-messages-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-get-messages-lambda-iam-role.name
}

#Allow the delete account endpoint to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda-delete-account-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-delete-account-lambda-iam-role.name
}

#Allow the get users endpoint to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda-get-users-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-get-users-lambda-iam-role.name
}

#Allow the login endpoint to access DynamoDB
resource "aws_iam_role_policy_attachment" "lambda-login-seng360DynamoDb_iam_policy-attachment" {
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
  role       = aws_iam_role.lambda-login-lambda-iam-role.name
}

#Create an internal VPC endpoint for dynamodb
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.devxp_vpc.id
  service_name = "com.amazonaws.us-west-2.dynamodb"
}

#Add endpoint to the route table
resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
  route_table_id  = aws_route_table.devxp_vpc_routetable_pub.id
}
