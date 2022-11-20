import json
from common import *

def lambda_handler(event, context):
    """
    Handler for calls to https://c11ipox830.execute-api.us-west-2.amazonaws.com/seng360/create_account
    """
    body = event.get("body")
    if type(body) is str:
        try:
            body = json.loads(event.get('body'))
        except Exception as e:
            return bad_request(f"failed to decode request body {e}")
    
    logging.info(body)

    username = body.get('username')
    password = body.get('password')
    public_key = body.get('public_key')

    logging.info(f"{username} {password} {public_key}")

    try:
        if dynamodb_table.get_item(Key={
            "userId": username
        }).get('Item') is not None:
            # username already exists
            return bad_request("username already exists")
    except Exception as e:
        return server_error(f"failed to check dynamodb {e}")

    token = generate_token()

    logging.info(f"token: {token}")

    try: 
        dynamodb_table.put_item(
            Item={
                'userId': username,
                'password': password,
                'publicKey': public_key,
                'messageQueue': '{}',
                'token': token,
                'tokenCreated': str(datetime.utcnow())
            }
        )
    except Exception as e:
        return server_error(f"failed to insert into dynamodb {e}")

    return response(200, token)
