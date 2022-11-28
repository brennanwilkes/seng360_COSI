# Standard library imports
import json
import logging
from hashlib import sha256
from datetime import datetime
from dateutil import parser

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

def parse_request(event):
    headers = event.get("headers")
    if type(headers) is str:
        try:
            headers = json.loads(event.get('headers'))
        except Exception as e:
            return bad_request(f"failed to decode request headers {e}")

    cookies = headers.get("Cookie")
    token = None
    if cookies is not None:
        try:
            token = cookies[7:]
        except:
            token = None

    body = event.get("body")
    logging.info(f'body before parse: {body}')
    if type(body) is str:
        try:
            body = json.loads(event.get('body'))
        except Exception as e:
            return bad_request(f"failed to decode request body {e}", token)

    return body, token

def response(status, data, token = None):
    response = {
        'statusCode': status,
        'headers': {
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(data),
    }
    if token is not None:
        response['headers']['Set-Cookie'] = f'cookie={token}'
    
    logger.info(f' Generated response: {response}')
    return response


def bad_request(message, token = None):
    return response(400, {'error': message}, token)


def server_error(message, token = None):
    return response(500, {'error': message}, token)


def generate_token():
    return sha256((str(datetime.utcnow()) + 'super spicy secret :)').encode('ascii'),  usedforsecurity=True).hexdigest()


def verify_token(token):
    items = dynamodb_table.scan().get('Items')
    for item in items:
        if item.get('token') == token:
            t: datetime = parser.parse(item.get('tokenCreated'))
            if (datetime.utcnow() - t).total_seconds() < 86400:
                # if cookie is younger than 24 hours
                return item
    
    return None
