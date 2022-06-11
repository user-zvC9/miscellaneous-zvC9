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


#mkdir -p "workdir/${netname}" || exit 1
#pushd    "workdir/${netname}" || exit 2

# sign CSRs

#mkdir -p "created_files_for_use/client/generated/${netname}" || error "mkdir" 3
#mkdir -p "created_files_for_use/server/generated/${netname}" || error "mkdir" 4
#cp -fv "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" "created_files_for_use/client/generated/${netname}/" || error cp 5
#cp -fv "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" "created_files_for_use/server/generated/${netname}/" || error cp 6

	openssl x509 -req -CA "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" -CAkey "workdir/${netname}/${netname}-ca.key.pem" \
	-CAserial "workdir/${netname}/${netname}-ca.serial.srl" \
	-CAcreateserial -out "created_files_for_use/server/generated/${netname}/${netname}-tls-server.ca-signed.cert.pem" -outform PEM \
	-inform PEM -in "created_files_for_use/server/generated/${netname}/${netname}-tls-server.csr.pem" || error openssl 3
	
	openssl x509 -req -CA "workdir/${netname}/${netname}-ca.selfsigned.cert.pem" -CAkey "workdir/${netname}/${netname}-ca.key.pem" \
	-CAserial "workdir/${netname}/${netname}-ca.serial.srl" \
	-CAcreateserial -out "created_files_for_use/client/generated/${netname}/${netname}-tls-client.ca-signed.cert.pem" -outform PEM \
	-inform PEM -in "created_files_for_use/client/generated/${netname}/${netname}-tls-client.csr.pem" || error openssl 4


