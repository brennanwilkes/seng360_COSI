from common import *

def lambda_handler(event, context):
    r = parse_request(event)
    if type(r) is dict:
        return r
    else:
        b, token = r
    
    item = verify_token(token)
    if item is not None:
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
            return server_error("database update failed", token)
        
        return response(200, item.get("messageQueue"), token)

    return bad_request("failed to verify cookie", token)