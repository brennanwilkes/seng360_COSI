from common import *

def lambda_handler(event, context):
    body, token = parse_request(event)
    
    if verify_token(token):
        item = dynamodb_table.get_item(Key={ "token": token }).get('Item')
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
            "body": item.get("messageQueue")
        }

    return bad_request("failed to verify cookie")