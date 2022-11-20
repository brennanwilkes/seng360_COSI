# Standard library imports
import json
import logging
from hashlib import sha256
from datetime import datetime

# Third party imports
import boto3

# configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# access environment variables
AWS_REGION = 'us-west-2'
TABLE_NAME = 'seng360DynamoDb'


dynamodb_resource = boto3.resource(
    'dynamodb',
    region_name=AWS_REGION
)
dynamodb_table = dynamodb_resource.Table(TABLE_NAME)

def response(status, data):
    response = {
        'statusCode': status,
        'headers': {
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(data),
    }
    logger.info(f' Generated response: {response}')
    return response


def bad_request(message):
    return response(400, {'error': message})


def server_error(message):
    return response(500, {'error': message})


def generate_token():
    return sha256(str(datetime.utcnow()) + 'super spicy secret :)',  usedforsecurity=True).hexdigest()


def verify_token(username, token):
    item = dynamodb_table.get_item(Key={ "userId": username }).get('Item')
    t: datetime = datetime.strptime(item.get('tokenCreated'))
    if (datetime.utcnow() - t).total_seconds() < 86400 and item.get('token') == token:
        # if cookie is younger than 24 hours
        return True

    return False


def lambda_handler(event, context):
    """
    Handler for calls to https://ads5u2p9gb.execute-api.us-west-2.amazonaws.com/seng360/create_account
    """
    body = event.get("body")
    if type(body) is str:
        try:
            body = json.loads(event.get('body'))
        except Exception as e:
            return bad_request(f"failed to decode request body {e}")

    logging.info(body)

    username = body.get('username')
    password = body.get('password')
    public_key = body.get('public_key')

    logging.info(f"{username} {password} {public_key}")

    try:
        if dynamodb_table.get_item(Key={
            "userId": username
        }).get('Item') is not None:
            # username already exists
            return bad_request("username already exists")
    except Exception as e:
        return server_error(f"failed to check dynamodb {e}")

    token = generate_token()

    logging.info(f"token: {token}")

    dynamodb_table.put_item(
        Item={
            'userId': username,
            'password': password,
            'publicKey': public_key,
            'messageQueue': None,
            'token': token,
            'tokenCreated': str(datetime.utcnow())
        }
    )

    return response(200, token)
