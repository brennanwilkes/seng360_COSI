import json
from common import *

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body'))
    except:
        return bad_request("failed to decode request body")

    username = body.get('username')
    token = body.get('cookie')

    if verify_token(username, token):
        res = dynamodb_table.delete_item(Key={
            "userId": username,
        })

        if res.get('Attributes').get('userId') == username:
            # success
            return {
                "statusCode": 200,
                "body": json.dumps('Hello World')
            }
        else:
            return server_error("failed to delete item")

    return bad_request("failed to verify cookie")