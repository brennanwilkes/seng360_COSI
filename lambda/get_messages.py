import json
from common import *

def lambda_handler(event, context):
    body, token = parse_request(event)

    username = body.get('username')
    recipient = body.get('to')
    message = body.get('message')
    
    if verify_token(username, token):
        item = dynamodb_table.get_item(Key={ "userId": recipient }).get('Item')
        if item is None:
            return bad_request("recipient does not exist")

        msg_queue = json.loads(item.get("messageQueue"))
        msg_queue[str(datetime.utcnow())] = json.dumps({
            'message': message,
            'sender': username,
        })
        res = dynamodb_table.update_item(
            Key={
                'userId': item.get('userId'),
            },
            UpdateExpression='set messageQueue=:d',
            ExpressionAttributeValues={
                ':d': json.dumps(msg_queue)
            },
        )
        if not res:
            return server_error("database update failed")
        
        return {
            "statusCode": 200,
            "body": 'updated message queue'
        }

    return bad_request("failed to verify cookie")