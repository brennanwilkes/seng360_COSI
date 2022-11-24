from common import *

def lambda_handler(event, context):
    body, token = parse_request(event)

    token = body.get('cookie')

    if verify_token(token):
        res = dynamodb_table.delete_item(Key={
            "token": token,
        })

        logging.info(f'delete result: {res}')

        if res.get('ResponseMetadata').get('HTTPStatusCode') == 200:
            # success
            return response(200, "successfully deleted account")
        else:
            return server_error("failed to delete item")

    return bad_request("failed to verify cookie")