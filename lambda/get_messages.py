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
        item = dynamodb_table.get_item(Key={ "userId": username }).get('Item')
        res = dynamodb_resource.update_item(
            Key={
                'userId': item.get('userId'),
            },
            UpdateExpression='set messageQueue=:d',
            ExpressionAttributeValues={
                ':d': None
            },
        )
        if not res:
            return server_error("database update failed")
        
        return {
            "statusCode": 200,
            "body": json.dumps(item.get("messageQueue"))
        }

    return bad_request("failed to verify cookie")
