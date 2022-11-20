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
