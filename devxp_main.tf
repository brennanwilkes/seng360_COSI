terraform {
  backend "s3" {
      bucket = "terraform-state-yll5dxd1nesgmp8k21rukrhcvkrhoflmsr8y9sfmecmrb"
      key = "terraform/state"
      region = "us-west-2"
  }
}

resource "aws_dynamodb_table" "DynamoDb-ewqh" {
      name = "DynamoDb-ewqh"
      hash_key = "userId"
      billing_mode = "PAY_PER_REQUEST"
      ttl {
        attribute_name = "TimeToExist"
        enabled = true
      }
      attribute {
        name = "userId"
        type = "S"
      }
}

resource "aws_iam_user" "DynamoDb-ewqh_iam" {
      name = "DynamoDb-ewqh_iam"
}

resource "aws_iam_user_policy_attachment" "DynamoDb-ewqh_iam_policy_attachment0" {
      user = aws_iam_user.DynamoDb-ewqh_iam.name
      policy_arn = aws_iam_policy.DynamoDb-ewqh_iam_policy0.arn
}

resource "aws_iam_policy" "DynamoDb-ewqh_iam_policy0" {
      name = "DynamoDb-ewqh_iam_policy0"
      path = "/"
      policy = data.aws_iam_policy_document.DynamoDb-ewqh_iam_policy_document.json
}

resource "aws_iam_access_key" "DynamoDb-ewqh_iam_access_key" {
      user = aws_iam_user.DynamoDb-ewqh_iam.name
}

resource "aws_iam_role" "lambda-send-message-lambda-iam-role" {
      name = "lambda-send-message-lambda-iam-role"
      assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

resource "aws_lambda_function" "lambda-send-message" {
      function_name = "lambda-send-message"
      role = aws_iam_role.lambda-send-message-lambda-iam-role.arn
      filename = "outputs/send_message.py.zip"
      runtime = "python3.9"
      source_code_hash = data.archive_file.lambda-send-message-archive.output_base64sha256
      handler = "send_message.lambda_handler"
      vpc_config {
        subnet_ids = [aws_subnet.devxp_vpc_subnet_public0.id]
        security_group_ids = [aws_security_group.devxp_security_group.id]
      }
}

resource "aws_iam_policy" "lambda-send-message-vpc-policy" {
      name = "lambda-send-message_vpc_policy"
      path = "/"
      policy = data.aws_iam_policy_document.lambda-send-message-vpc-policy-document.json
}

resource "aws_iam_role_policy_attachment" "lambda-send-message-vpc-policy-attachment" {
      policy_arn = aws_iam_policy.lambda-send-message-vpc-policy.arn
      role = aws_iam_role.lambda-send-message-lambda-iam-role.name
}

resource "aws_iam_role" "lambda-get-messages-lambda-iam-role" {
      name = "lambda-get-messages-lambda-iam-role"
      assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

resource "aws_lambda_function" "lambda-get-messages" {
      function_name = "lambda-get-messages"
      role = aws_iam_role.lambda-get-messages-lambda-iam-role.arn
      filename = "outputs/get_messages.py.zip"
      runtime = "python3.9"
      source_code_hash = data.archive_file.lambda-get-messages-archive.output_base64sha256
      handler = "get_messages.lambda_handler"
      vpc_config {
        subnet_ids = [aws_subnet.devxp_vpc_subnet_public0.id]
        security_group_ids = [aws_security_group.devxp_security_group.id]
      }
}

resource "aws_iam_policy" "lambda-get-messages-vpc-policy" {
      name = "lambda-get-messages_vpc_policy"
      path = "/"
      policy = data.aws_iam_policy_document.lambda-get-messages-vpc-policy-document.json
}

resource "aws_iam_role_policy_attachment" "lambda-get-messages-vpc-policy-attachment" {
      policy_arn = aws_iam_policy.lambda-get-messages-vpc-policy.arn
      role = aws_iam_role.lambda-get-messages-lambda-iam-role.name
}

resource "aws_iam_role" "lambda-delete-account-lambda-iam-role" {
      name = "lambda-delete-account-lambda-iam-role"
      assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

resource "aws_lambda_function" "lambda-delete-account" {
      function_name = "lambda-delete-account"
      role = aws_iam_role.lambda-delete-account-lambda-iam-role.arn
      filename = "outputs/delete_account.py.zip"
      runtime = "python3.9"
      source_code_hash = data.archive_file.lambda-delete-account-archive.output_base64sha256
      handler = "delete_account.lambda_handler"
      vpc_config {
        subnet_ids = [aws_subnet.devxp_vpc_subnet_public0.id]
        security_group_ids = [aws_security_group.devxp_security_group.id]
      }
}

resource "aws_iam_policy" "lambda-delete-account-vpc-policy" {
      name = "lambda-delete-account_vpc_policy"
      path = "/"
      policy = data.aws_iam_policy_document.lambda-delete-account-vpc-policy-document.json
}

resource "aws_iam_role_policy_attachment" "lambda-delete-account-vpc-policy-attachment" {
      policy_arn = aws_iam_policy.lambda-delete-account-vpc-policy.arn
      role = aws_iam_role.lambda-delete-account-lambda-iam-role.name
}

resource "aws_iam_role" "lambda-create-account-lambda-iam-role" {
      name = "lambda-create-account-lambda-iam-role"
      assume_role_policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Action\": \"sts:AssumeRole\",\n      \"Principal\": {\n        \"Service\": \"lambda.amazonaws.com\"\n      },\n      \"Effect\": \"Allow\",\n      \"Sid\": \"\"\n    }\n  ]\n}"
}

resource "aws_lambda_function" "lambda-create-account" {
      function_name = "lambda-create-account"
      role = aws_iam_role.lambda-create-account-lambda-iam-role.arn
      filename = "outputs/create_account.py.zip"
      runtime = "python3.9"
      source_code_hash = data.archive_file.lambda-create-account-archive.output_base64sha256
      handler = "create_account.lambda_handler"
      vpc_config {
        subnet_ids = [aws_subnet.devxp_vpc_subnet_public0.id]
        security_group_ids = [aws_security_group.devxp_security_group.id]
      }
}

resource "aws_iam_policy" "lambda-create-account-vpc-policy" {
      name = "lambda-create-account_vpc_policy"
      path = "/"
      policy = data.aws_iam_policy_document.lambda-create-account-vpc-policy-document.json
}

resource "aws_iam_role_policy_attachment" "lambda-create-account-vpc-policy-attachment" {
      policy_arn = aws_iam_policy.lambda-create-account-vpc-policy.arn
      role = aws_iam_role.lambda-create-account-lambda-iam-role.name
}

resource "aws_subnet" "devxp_vpc_subnet_public0" {
      vpc_id = aws_vpc.devxp_vpc.id
      cidr_block = "10.0.0.0/25"
      map_public_ip_on_launch = true
      availability_zone = "us-west-2a"
}

resource "aws_subnet" "devxp_vpc_subnet_public1" {
      vpc_id = aws_vpc.devxp_vpc.id
      cidr_block = "10.0.128.0/25"
      map_public_ip_on_launch = true
      availability_zone = "us-west-2b"
}

resource "aws_internet_gateway" "devxp_vpc_internetgateway" {
      vpc_id = aws_vpc.devxp_vpc.id
}

resource "aws_route_table" "devxp_vpc_routetable_pub" {
      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devxp_vpc_internetgateway.id
      }
      vpc_id = aws_vpc.devxp_vpc.id
}

resource "aws_route" "devxp_vpc_internet_route" {
      route_table_id = aws_route_table.devxp_vpc_routetable_pub.id
      destination_cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.devxp_vpc_internetgateway.id
}

resource "aws_route_table_association" "devxp_vpc_subnet_public_assoc" {
      subnet_id = aws_subnet.devxp_vpc_subnet_public0.id
      route_table_id = aws_route_table.devxp_vpc_routetable_pub.id
}

resource "aws_vpc" "devxp_vpc" {
      cidr_block = "10.0.0.0/16"
      enable_dns_support = true
      enable_dns_hostnames = true
}

resource "aws_security_group" "devxp_security_group" {
      vpc_id = aws_vpc.devxp_vpc.id
      name = "devxp_security_group"
      ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
}

data "aws_iam_policy_document" "DynamoDb-ewqh_iam_policy_document" {
      statement {
        actions = ["dynamodb:DescribeTable", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchGet*", "dynamodb:DescribeStream", "dynamodb:DescribeTable", "dynamodb:Get*", "dynamodb:Query", "dynamodb:Scan", "dynamodb:BatchWrite*", "dynamodb:CreateTable", "dynamodb:Delete*", "dynamodb:Update*", "dynamodb:PutItem"]
        effect = "Allow"
        resources = [aws_dynamodb_table.DynamoDb-ewqh.arn]
      }
      statement {
        actions = ["dynamodb:List*", "dynamodb:DescribeReservedCapacity*", "dynamodb:DescribeLimits", "dynamodb:DescribeTimeToLive"]
        effect = "Allow"
        resources = ["*"]
      }
}

data "archive_file" "lambda-send-message-archive" {
      type = "zip"
      source_file = "lambda/send_message.py"
      output_path = "outputs/send_message.py.zip"
}

data "aws_iam_policy_document" "lambda-send-message-vpc-policy-document" {
      statement {
        effect = "Allow"
        actions = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
        resources = ["*"]
      }
}

data "archive_file" "lambda-get-messages-archive" {
      type = "zip"
      source_file = "lambda/get_messages.py"
      output_path = "outputs/get_messages.py.zip"
}

data "aws_iam_policy_document" "lambda-get-messages-vpc-policy-document" {
      statement {
        effect = "Allow"
        actions = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
        resources = ["*"]
      }
}

data "archive_file" "lambda-delete-account-archive" {
      type = "zip"
      source_file = "lambda/delete_account.py"
      output_path = "outputs/delete_account.py.zip"
}

data "aws_iam_policy_document" "lambda-delete-account-vpc-policy-document" {
      statement {
        effect = "Allow"
        actions = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
        resources = ["*"]
      }
}

data "archive_file" "lambda-create-account-archive" {
      type = "zip"
      source_file = "lambda/create_account.py"
      output_path = "outputs/create_account.py.zip"
}

data "aws_iam_policy_document" "lambda-create-account-vpc-policy-document" {
      statement {
        effect = "Allow"
        actions = ["ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs", "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface"]
        resources = ["*"]
      }
}



