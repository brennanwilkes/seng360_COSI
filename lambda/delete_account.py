import json
from common import *

def lambda_handler(event, context):
    body = event.get("body")
    if type(body) is str:
        try:
            body = json.loads(event.get('body'))
        except Exception as e:
            return bad_request(f"failed to decode request body {e}")

    username = body.get('username')
    token = body.get('cookie')

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