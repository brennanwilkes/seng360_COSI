from common import *

def lambda_handler(event, context):
    r = parse_request(event)
    if type(r) is dict:
        return r
    else:
        body, token = r

    #Hash password to reduce severity of a data breech
    username = body.get("username")
    password = sha256(body.get("password").encode('ascii')).hexdigest()

    item = dynamodb_table.get_item(Key={ "userId": username }).get('Item')
    if password == item.get("password"):
        token = generate_token()

        logging.info(f"new token: {token}")

        #Update user token to a fresh nonce
        try:
            res = dynamodb_table.update_item(
                Key={
                    'userId': username,
                },
                UpdateExpression='set #tok=:d',
                ExpressionAttributeValues={
                    ':d': token
                },
                ExpressionAttributeNames={
                    '#tok': 'token'
                }
            )
            if not res:
                return server_error("database update failed", token)

            return response(200, "updated token", token)
        except Exception as e:
            return server_error(f"failed to insert into dynamodb {e}")
    else:
        return bad_request("update failed")
