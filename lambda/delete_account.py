from common import *

def lambda_handler(event, context):
    r = parse_request(event)
    if type(r) is dict:
        return r
    else:
        body, token = r

    password = sha256(body.get('password').encode('ascii')).hexdigest()

    item = verify_token(token)
    if item is not None:
        if item.get('password') == password:
            res = dynamodb_table.delete_item(Key={
                "userId": item.get("userId"),
            })

            logging.info(f'delete result: {res}')

            if res.get('ResponseMetadata').get('HTTPStatusCode') == 200:
                # success
                return response(200, "successfully deleted account")
            else:
                return server_error("failed to delete item", token)
        else:
            return bad_request("invalid credentials", token)

    return bad_request("failed to verify cookie", token)