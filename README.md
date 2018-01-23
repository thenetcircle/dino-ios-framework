# dino-ios-framework #

This Framework is designed to allow for connections to a Dino server

### How do I set up? ###
Can't get logged in directly. Please get access token by call the following api first.

User ID = 179906 

        curl -k -X "POST" "https://red.tianwen.php7.hallokoko.lab/api_dev.php/v2/auth/access_token.json" \
     -H 'Cookie: session_id=1a6ed908d2cd75b8734f8cdad96c98313ecbb6a2' \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
        "username": "cool@qq.com",
        "password": "121212",
        "client_id": "koko",
        "grant_type": "password"
        }'

### What can I do with the demo? ###
* Connect / disconnect to the server
* Get logged in
* List channels
* List rooms
* Join rooms
* Send messages
* Receive messages
* Send / receive acks (sent, delivered, read)
* ...


### Who do I talk to? ###

Please speak to Devin - devin@thenetcircle.com
