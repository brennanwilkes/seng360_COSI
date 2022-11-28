from common import *

def lambda_handler(event, context):
    r = parse_request(event)
    if type(r) is dict:
        return r
    else:
        body, token = r
    
    username = body.get('username')
    item = dynamodb_table.get_item(Key={ "userId": username }).get('Item')
    if item is not None:
        key = item.get("publicKey")
        if key is not None:
            return response(200, key, token)
    
    return bad_request("failed to find user in database")
