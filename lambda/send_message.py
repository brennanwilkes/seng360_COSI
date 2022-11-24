import json
from common import *

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body'))
    except:
        return bad_request("failed to decode request body")

    token = body.get('cookie')
    recipient = body.get('to')
    message = body.get('message')
    
    if verify_token(token):
        item = dynamodb_table.get_item(Key={ "userId": recipient }).get('Item')
        sender = dynamodb_table.get_item(Key={ "token": token }).get('Item')
        msg_queue = json.loads(item.get("messageQueue"))
        msg_queue[str(datetime.utcnow())] = json.dumps({
            'message': message,
            'sender': sender.get('Attributes').get('userId'),
        })
        res = dynamodb_resource.update_item(
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
