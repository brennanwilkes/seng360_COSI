from common import *

def lambda_handler(event, context):
    """
    Handler for calls to https://c11ipox830.execute-api.us-west-2.amazonaws.com/seng360/create_account
    """
    r = parse_request(event)
    if type(r) is dict:
        return r
    else:
        body, t = r

    logging.info(body)

    #Grab user provided information
    username = body.get('username')

    #Ensure password is hashed to prevent the severity of data breechs
    password = sha256(body.get('password').encode('ascii')).hexdigest()
    public_key = body.get('public_key')
    prekeySign = body.get('prekeySign')

    logging.info(f"{username} {password} {public_key} {prekeySign}")

    #Ensure user ID is new and unique
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

    #Save user to datastore
    try:
        dynamodb_table.put_item(
            Item={
                'userId': username,
                'password': password,
                'publicKey': public_key,
                'prekeySign': prekeySign,
                'messageQueue': '{}',
                'token': token,
                'tokenCreated': str(datetime.utcnow())
            }
        )
    except Exception as e:
        return server_error(f"failed to insert into dynamodb {e}")

    return response(200, "account created", token)
