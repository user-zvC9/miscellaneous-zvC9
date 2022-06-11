#!/bin/bash
# Generating self-signed key manually:
 #Country Name (2 letter code) [AU]:RU
 #State or Province Name (full name) [Some-State]:State
 #Locality Name (eg, city) []:City
 #Organization Name (eg, company) [Internet Widgits ...]:Company
 #Organizational Unit Name (eg, section) []:Section
 #Common Name (e.g. server FQDN or YOUR name) []:ca
 #Email Address []:

## ed25519 is used
#bits="16384" # rsa
dhbits="4096"
days="100000"

netname="template-net"

#bits="4096" # rsa
#dhbits="4096"
#days="100000"

umask 7077

server_private_ip="10.11.12.0"
client_private_ip="10.11.12.1"

# this can be white public IPv4 address like 8.9.10.11
server_public_ip="192.168.1.100"

server_udp_port="12005"

function error {
 if [ $# -ge 2 ] ; then
  echo "$1"
  exit $2
 else
  if [ $# -ge 1 ] ; then
   echo "$1"
   exit 1
  else
   exit 1
  fi
 fi
}

