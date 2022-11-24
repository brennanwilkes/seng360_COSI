import json
from common import *

def lambda_handler(event, context):
    body, token = parse_request(event)

    username = body.get('username')

    if verify_token(username, token):
        res = dynamodb_table.delete_item(Key={
            "userId": username,
        })

        logging.info(f'delete result: {res}')

        if res.get('ResponseMetadata').get('HTTPStatusCode') == 200:
            # success
            return response(200, "successfully deleted account")
        else:
            return server_error("failed to delete item")

    return bad_request("failed to verify cookie")