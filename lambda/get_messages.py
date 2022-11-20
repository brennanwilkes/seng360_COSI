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
        item = dynamodb_table.get_item(Key={ "userId": username }).get('Item')
        res = dynamodb_table.update_item(
            Key={
                'userId': item.get('userId'),
            },
            UpdateExpression='set messageQueue=:d',
            ExpressionAttributeValues={
                ':d': '{}'
            },
        )
        if not res:
            return server_error("database update failed")
        
        return {
            "statusCode": 200,
            "body": json.dumps(item.get("messageQueue"))
        }

    return bad_request("failed to verify cookie")
