#!/bin/bash

wg genkey | sudo tee /etc/wireguard/private.key
chmod go= /etc/wireguard/private.key
cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key

# Read the private and public keys from their respective files
PRIVATE_KEY=$(cat /etc/wireguard/private.key)
PUBLIC_KEY=$(cat /etc/wireguard/public.key)

# Send POST request and store the response in a variable
response=$(curl -s -X POST http://157.245.96.121:8000/get_ip \
-H "Content-Type: application/json" \
-d "{\"public_key\": \"$PUBLIC_KEY\"}")

# Parse the number from the response and store in a Bash variable
number=$(echo $response | jq '.number')


# Check if the keys were read correctly. If not, exit the script.
if [ -z "$PRIVATE_KEY" ]; then
    echo "Private key could not be read."
    exit 1
fi

if [ -z "$PUBLIC_KEY" ]; then
    echo "Public key could not be read."
    exit 1
fi


# Configuration template
config="[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.8.0.$number/24

[Peer]
PublicKey = A9D1f+HVpyV+H7h4mtuJy0p/LJ/kfzTMawXF/L/p5lQ=
AllowedIPs = 10.8.0.0/24
Endpoint = 157.245.96.121:51820"

# Write to wg0.conf
echo "$config" | sudo tee /etc/wireguard/wg0.conf > /dev/null

curl -s -X POST http://157.245.96.121:8000/add_peer -H "Content-Type: application/json" -d "{\"public_key\": \"$PUBLIC_KEY\", \"number\": \"$number\"}"

wg-quick up wg0
ping -c 5 10.8.0.1

tail -f /dev/null
#../bin/spark-submit --jars ../jars/hadoop-aws-3.3.4.jar,../jars/aws-java-sdk-bundle-1.12.608.jar s3_wc.py
