import json
from common import *

def lambda_handler(event, context):
    r = parse_request(event)
    if type(r) is dict:
        return r
    else:
        body, token = r

    recipient = body.get('to')
    message = body.get('message')

    sender = verify_token(token)
    logging.info(f"verify_token result: {sender}")
    if sender is not None:

        #Grab user information of recipient
        recip_item = dynamodb_table.get_item(Key={ "userId": recipient }).get('Item')

        #Get recipient's message queue
        msg_queue = json.loads(recip_item.get("messageQueue"))

        #Add new message to the queue
        msg_queue[str(datetime.utcnow())] = json.dumps({
            'message': message,
            'sender': sender.get('userId'),
        })

        #Update the queue in DynamoDB
        res = dynamodb_table.update_item(
            Key={
                'userId': recip_item.get('userId'),
            },
            UpdateExpression='set messageQueue=:d',
            ExpressionAttributeValues={
                ':d': json.dumps(msg_queue)
            },
        )
        if not res:
            return server_error("database update failed", token)

        return response(200, "updated message queue", token)

    return bad_request("failed to verify cookie", token)
