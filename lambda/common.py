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

#Dynamodb resource creation
dynamodb_resource = boto3.resource(
    'dynamodb',
    region_name=AWS_REGION
)
dynamodb_table = dynamodb_resource.Table(TABLE_NAME)

#Utility function for parsing HTTP requests
def parse_request(event):

    #Validate HTTP headers recieved
    headers = event.get("headers")
    if type(headers) is str:
        try:
            headers = json.loads(event.get('headers'))
        except Exception as e:
            return bad_request(f"failed to decode request headers {e}")

    #Validate HTTP cookies recieved
    cookies = headers.get("Cookie")
    token = None
    if cookies is not None:
        try:
            token = cookies[7:]
        except:
            token = None

    #Validate HTTP request body
    body = event.get("body")
    logging.info(f'body before parse: {body}')
    if type(body) is str:
        try:
            body = json.loads(event.get('body'))
        except Exception as e:
            return bad_request(f"failed to decode request body {e}", token)

    #Return validated data
    return body, token

#Utility method for creating HTTP responses in a common API format
def response(status, data, token = None):

    #Main HTTP structure
    response = {
        'statusCode': status,
        'headers': {
            'Access-Control-Allow-Origin': '*',
        },
        'body': json.dumps(data),
    }

    #Set token in response cookies
    if token is not None:
        response['headers']['Set-Cookie'] = f'cookie={token}'

    #Debug loggins
    logger.info(f' Generated response: {response}')
    return response

#API Bad Format Response
def bad_request(message, token = None):
    return response(400, {'error': message}, token)

#API Unknown Error Response ("oops!")
def server_error(message, token = None):
    return response(500, {'error': message}, token)

#Utility function for generating a nonce (extra spicy)
def generate_token():
    return sha256((str(datetime.utcnow()) + 'super spicy secret :)').encode('ascii'),  usedforsecurity=True).hexdigest()

#Token verification helper
def verify_token(token):

    #Retrieve data store entries
    items = dynamodb_table.scan().get('Items')
    for item in items:

        #Compare tokens
        if item.get('token') == token:

            #Ensure no replay attacks
            t: datetime = parser.parse(item.get('tokenCreated'))
            if (datetime.utcnow() - t).total_seconds() < 86400:

                # if cookie is younger than 24 hours
                return item

    return None
