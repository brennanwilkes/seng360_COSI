#Root block for global cloud infastructure information
terraform {
  backend "s3" {
    #This is not a secret
    bucket = "terraform-state-xll4dxd1nesgmp8k21rukrhcvkrhoflmsr8y9sfmecmrb"
    key    = "terraform/state"
    region = "us-west-2"
  }
}

#Main DynamoDB table
resource "aws_dynamodb_table" "seng360DynamoDb" {
  name         = "seng360DynamoDb"
  hash_key     = "userId"
  billing_mode = "PAY_PER_REQUEST"
  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }
  attribute {
    name = "userId"
    type = "S"
  }
}

#Access control for Dynamodb
resource "aws_iam_user" "seng360DynamoDb_iam" {
  name = "seng360DynamoDb_iam"
}

resource "aws_iam_user_policy_attachment" "seng360DynamoDb_iam_policy_attachment0" {
  user       = aws_iam_user.seng360DynamoDb_iam.name
  policy_arn = aws_iam_policy.seng360DynamoDb_iam_policy0.arn
}

resource "aws_iam_policy" "seng360DynamoDb_iam_policy0" {
  name   = "seng360DynamoDb_iam_policy0"
  path   = "/"
  policy = data.aws_iam_policy_document.seng360DynamoDb_iam_policy_document.json
}

resource "aws_iam_access_key" "seng360DynamoDb_iam_access_key" {
  user = aws_iam_user.seng360DynamoDb_iam.name
}

#Access control for send message endpoint
resource "aws_iam_role" "lambda-send-message-lambda-iam-role" {
  name               = "lambda-send-message-lambda-iam-role"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

#send message endpoint
resource "aws_lambda_function" "lambda-send-message" {
  function_name    = "lambda-send-message"
  role             = aws_iam_role.lambda-send-message-lambda-iam-role.arn
  filename         = "outputs/send_message.py.zip"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda-send-message-archive.output_base64sha256
  handler          = "send_message.lambda_handler"
  vpc_config {
    subnet_ids         = [aws_subnet.devxp_vpc_subnet_public0.id]
    security_group_ids = [aws_security_group.devxp_security_group.id]
  }
}

#Access control for send message endpoint
resource "aws_iam_policy" "lambda-send-message-vpc-policy" {
  name   = "lambda-send-message_vpc_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda-send-message-vpc-policy-document.json
}

#Access control for send message endpoint
resource "aws_iam_role_policy_attachment" "lambda-send-message-vpc-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-send-message-vpc-policy.arn
  role       = aws_iam_role.lambda-send-message-lambda-iam-role.name
}

#Access control for get messages endpoint
resource "aws_iam_role" "lambda-get-messages-lambda-iam-role" {
  name               = "lambda-get-messages-lambda-iam-role"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

#Get message endpoint
resource "aws_lambda_function" "lambda-get-messages" {
  function_name    = "lambda-get-messages"
  role             = aws_iam_role.lambda-get-messages-lambda-iam-role.arn
  filename         = "outputs/get_messages.py.zip"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda-get-messages-archive.output_base64sha256
  handler          = "get_messages.lambda_handler"
  vpc_config {
    subnet_ids         = [aws_subnet.devxp_vpc_subnet_public0.id]
    security_group_ids = [aws_security_group.devxp_security_group.id]
  }
}

#Access control for get messages endpoint
resource "aws_iam_policy" "lambda-get-messages-vpc-policy" {
  name   = "lambda-get-messages_vpc_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda-get-messages-vpc-policy-document.json
}

#Access control for get messages endpoint
resource "aws_iam_role_policy_attachment" "lambda-get-messages-vpc-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-get-messages-vpc-policy.arn
  role       = aws_iam_role.lambda-get-messages-lambda-iam-role.name
}

#Access control for delete account endpoint
resource "aws_iam_role" "lambda-delete-account-lambda-iam-role" {
  name               = "lambda-delete-account-lambda-iam-role"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

#Delete Account endpoint
resource "aws_lambda_function" "lambda-delete-account" {
  function_name    = "lambda-delete-account"
  role             = aws_iam_role.lambda-delete-account-lambda-iam-role.arn
  filename         = "outputs/delete_account.py.zip"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda-delete-account-archive.output_base64sha256
  handler          = "delete_account.lambda_handler"
  vpc_config {
    subnet_ids         = [aws_subnet.devxp_vpc_subnet_public0.id]
    security_group_ids = [aws_security_group.devxp_security_group.id]
  }
}

#Access control for get messages endpoint
resource "aws_iam_policy" "lambda-delete-account-vpc-policy" {
  name   = "lambda-delete-account_vpc_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda-delete-account-vpc-policy-document.json
}

#Access control for get messages endpoint
resource "aws_iam_role_policy_attachment" "lambda-delete-account-vpc-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-delete-account-vpc-policy.arn
  role       = aws_iam_role.lambda-delete-account-lambda-iam-role.name
}

#Access control for create account endpoint
resource "aws_iam_role" "lambda-create-account-lambda-iam-role" {
  name               = "lambda-create-account-lambda-iam-role"
  assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

#Create Account endpoint
resource "aws_lambda_function" "lambda-create-account" {
  function_name    = "lambda-create-account"
  role             = aws_iam_role.lambda-create-account-lambda-iam-role.arn
  filename         = "outputs/create_account.py.zip"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda-create-account-archive.output_base64sha256
  handler          = "create_account.lambda_handler"
  vpc_config {
    subnet_ids         = [aws_subnet.devxp_vpc_subnet_public0.id]
    security_group_ids = [aws_security_group.devxp_security_group.id]
  }
}

#Access control for create account endpoint
resource "aws_iam_policy" "lambda-create-account-vpc-policy" {
  name   = "lambda-create-account_vpc_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.lambda-create-account-vpc-policy-document.json
}

#Access control for create account endpoint
resource "aws_iam_role_policy_attachment" "lambda-create-account-vpc-policy-attachment" {
  policy_arn = aws_iam_policy.lambda-create-account-vpc-policy.arn
  role       = aws_iam_role.lambda-create-account-lambda-iam-role.name
}

#Main VPC Subnets for network connections
resource "aws_subnet" "devxp_vpc_subnet_public0" {
  vpc_id                  = aws_vpc.devxp_vpc.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}

resource "aws_subnet" "devxp_vpc_subnet_public1" {
  vpc_id                  = aws_vpc.devxp_vpc.id
  cidr_block              = "10.0.128.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
}

#Internet gateway for external connections
resource "aws_internet_gateway" "devxp_vpc_internetgateway" {
  vpc_id = aws_vpc.devxp_vpc.id
}

#Route table for APIs
resource "aws_route_table" "devxp_vpc_routetable_pub" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devxp_vpc_internetgateway.id
  }
  vpc_id = aws_vpc.devxp_vpc.id
}

resource "aws_route" "devxp_vpc_internet_route" {
  route_table_id         = aws_route_table.devxp_vpc_routetable_pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devxp_vpc_internetgateway.id
}

resource "aws_route_table_association" "devxp_vpc_subnet_public_assoc" {
  subnet_id      = aws_subnet.devxp_vpc_subnet_public0.id
  route_table_id = aws_route_table.devxp_vpc_routetable_pub.id
}

#Main Virtual Private Cloud
resource "aws_vpc" "devxp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#Network security rules
#Essentially only allow HTTP traffic, no SSH or direct database connections!
resource "aws_security_group" "devxp_security_group" {
  vpc_id = aws_vpc.devxp_vpc.id
  name   = "devxp_security_group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Access control for DynamoDB
data "aws_iam_policy_document" "seng360DynamoDb_iam_policy_document" {
  statement {
    actions   = ["dynamodb:DescribeTable", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchGet*", "dynamodb:DescribeStream", "dynamodb:DescribeTable", "dynamodb:Get*", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchWrite*", "dynamodb:CreateTable", "dynamodb:Delete*", "dynamodb:Update*", "dynamodb:PutItem"]
    effect    = "Allow"
    resources = [aws_dynamodb_table.seng360DynamoDb.arn]
  }
  statement {
    actions   = ["dynamodb:List*", "dynamodb:DescribeReservedCapacity*", "dynamodb:DescribeLimits", "dynamodb:DescribeTimeToLive"]
    effect    = "Allow"
    resources = ["*"]
  }
}

#Source code for send messages endpoint
data "archive_file" "lambda-send-message-archive" {
  type        = "zip"
  source_dir  = "lambda/"
  excludes    = setsubtract(fileset("lambda/", "*"), ["send_message.py", "common.py"])
  output_path = "outputs/send_message.py.zip"
}

#Access control for send messages endpoint
data "aws_iam_policy_document" "lambda-send-message-vpc-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
}

#Source code for get messages endpoint
data "archive_file" "lambda-get-messages-archive" {
  type        = "zip"
  source_dir  = "lambda/"
  excludes    = setsubtract(fileset("lambda/", "*"), ["get_messages.py", "common.py"])
  output_path = "outputs/get_messages.py.zip"
}

#Access control for get messages endpoint
data "aws_iam_policy_document" "lambda-get-messages-vpc-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
}

#Source code for delete account endpoint
data "archive_file" "lambda-delete-account-archive" {
  type        = "zip"
  source_dir  = "lambda/"
  excludes    = setsubtract(fileset("lambda/", "*"), ["delete_account.py", "common.py"])
  output_path = "outputs/delete_account.py.zip"
}

#Access control for delete account endpoint
data "aws_iam_policy_document" "lambda-delete-account-vpc-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
}

#Source code for create account endpoint
data "archive_file" "lambda-create-account-archive" {
  type        = "zip"
  source_dir  = "lambda/"
  excludes    = setsubtract(fileset("lambda/", "*"), ["create_account.py", "common.py"])
  output_path = "outputs/create_account.py.zip"
}

#Access control for create account endpoint
data "aws_iam_policy_document" "lambda-create-account-vpc-policy-document" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
    resources = ["*"]
  }
}
