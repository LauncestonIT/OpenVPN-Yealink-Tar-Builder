#!/bin/sh

if [ $# -eq 0 ]; then
  echo "Missing filename"
  exit 1
fi

ovpn_file="$1"

mkdir openvpn
mkdir ./openvpn/keys

# Extract the needed parts
awk '/\<ca>/{exit}1' $ovpn_file > ./openvpn/vpn.cnf
awk '/<tls-auth>/ {flag=1; next} /<\/tls-auth>/ {flag=0} flag' $ovpn_file > ./openvpn/keys/ta.key
awk '/<cert>/ {flag=1; next} /<\/cert>/ {flag=0} flag' $ovpn_file > ./openvpn/keys/client.crt
awk '/<ca>/ {flag=1; next} /<\/ca>/ {flag=0} flag' $ovpn_file > ./openvpn/keys/ca.crt
awk '/<key>/ {flag=1; next} /<\/key>/ {flag=0} flag' $ovpn_file > ./openvpn/keys/client.key

cd openvpn

{
    echo "ca /config/openvpn/keys/ca.crt"
    echo "cert /config/openvpn/keys/client.crt"
    echo "key /config/openvpn/keys/client.key"
    echo "tls-auth /config/openvpn/keys/ta.key"
} >> vpn.cnf

tar -cf ../openvpn.tar keys vpn.cnf

# Clean up files
rm -r ../openvpn
