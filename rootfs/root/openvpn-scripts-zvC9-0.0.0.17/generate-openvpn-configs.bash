#!/bin/bash
# Generating self-signed key manually:
 #Country Name (2 letter code) [AU]:RU
 #State or Province Name (full name) [Some-State]:State
 #Locality Name (eg, city) []:City
 #Organization Name (eg, company) [Internet Widgits ...]:Company
 #Organizational Unit Name (eg, section) []:Section
 #Common Name (e.g. server FQDN or YOUR name) []:ca
 #Email Address []:

source bashlib/openvpn-openssl-vars.bash || exit 1


#mkdir -p "created_files_for_use/client/generated/${netname}" || exit 1
#pushd    "created_files_for_use/client/generated/${netname}" || exit 2

mkdir -p "created_files_for_use/client" || exit 1
pushd    "created_files_for_use/client" || exit 2


# not for android
cat > "${netname}-tls-client.conf" << EOF
mode p2p
remote $server_public_ip $server_udp_port udp
float
nobind
dev ${netname}-clt
dev-type tun
#topology net30
#topology subnet
topology p2p
ifconfig  $client_private_ip   $server_private_ip
# route ip mask gw
#route 0.0.0.0   0.0.0.0  10.11.94.0  

mssfix 1400
ping 5
ping-restart 30
persist-tun
tls-client

ca generated/${netname}/${netname}-ca.selfsigned.cert.pem
#dh output/dh.pem
cert generated/${netname}/${netname}-tls-client.ca-signed.cert.pem
key generated/${netname}/${netname}-tls-client.key.pem

tls-timeout 10
reneg-bytes 10485760
reneg-sec 60
# remote name
verify-x509-name ${netname}-tls-server name
cipher AES-256-CBC
tls-version-min 1.3
#route   0.0.0.0   0.0.0.0   $server_private_ip   5000
EOF

popd

#mkdir -p "created_files_for_use/server/generated/${netname}" || exit 1
#pushd    "created_files_for_use/server/generated/${netname}" || exit 2

mkdir -p "created_files_for_use/server" || exit 3
pushd    "created_files_for_use/server" || exit 4

cat > "${netname}-tls-server.conf" << EOF
#mode server
mode p2p
#remote example.net 1194 udp
lport $server_udp_port
float
#nobind
dev ${netname}-srv
dev-type tun
# topology net30
#topology subnet
topology p2p
ifconfig  $server_private_ip $client_private_ip
#ifconfig-pool 10.12.12.2 10.12.12.254 255.255.255.0
## route not used
#push "route-gateway 10.12.12.1"
mssfix 1400
ping 5
ping-restart 30
persist-tun
tls-server
#ca dir/openssl/ca/ca.pem
#dh dir/openssl/dh/dh.pem
#cert dir/openssl/users/tls-server/tls-server.cert.pem
#key dir/openssl/users/tls-server/tls-server.key

ca generated/$netname/${netname}-ca.selfsigned.cert.pem
dh generated/$netname/${netname}-dh.pem
cert generated/$netname/${netname}-tls-server.ca-signed.cert.pem
key generated/$netname/${netname}-tls-server.key.pem

tls-timeout 10
reneg-bytes 10485760
reneg-sec 60
# remote name
verify-x509-name ${netname}-tls-client name
cipher AES-256-CBC
#route   0.0.0.0   0.0.0.0   $client_private_ip   5000
tls-version-min 1.3
EOF

popd

echo "You have to MANUALLY EDIT GENERATED OpenVPN CONFIGS"


