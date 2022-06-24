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


mkdir -p "created_files_for_use/client/generated/${netname}" || exit 1
pushd    "created_files_for_use/client/generated/${netname}" || exit 2




# generate self-signed keys
 for name in  ${netname}-tls-client ; do
  echo -en "RU\\nState\\nCity\\nCompany\\nSection\\n${name}\\n\\n"\
  | openssl req -x509 -newkey ED25519 -nodes -outform PEM -out \
  ${name}.selfsigned.cert.pem -keyout ${name}.key.pem -keyform \
  PEM -days ${days} # -newkey rsa:$bits
 done 

# Generating certificate signing request manually:
 #Country Name (2 letter code) [AU]:RU
 #State or Province Name (full name) [Some-State]:S
 #Locality Name (eg, city) []:S
 #Organization Name (eg, company) [Internet Widgits Pty Ltd]:S
 #Organizational Unit Name (eg, section) []:S
 #Common Name (e.g. server FQDN or YOUR name) []:S
 #Email Address []:
 #
 #Please enter the following 'extra' attributes
 #to be sent with your certificate request
 #A challenge password []:
 #An optional company name []:

# generate CSRs (certificate signing requests)
 for name in ${netname}-tls-client ; do
  echo -en \
   "RU\\nState\\nCity\\nCompany\\nSection\\n${name}\\n\\n\\n\\n" |\
   openssl req -new -outform PEM -out ${name}.csr.pem -key \
   ${name}.key.pem -keyform PEM
 done

popd

