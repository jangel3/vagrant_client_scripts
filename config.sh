#! /bin/bash

set -e
set -x

SERVER_IP_ADDR=192.168.19.15
SERVER_FQDN=ipaserver.example.com
SERVER_NAME=ipaserver
IPA_REALM=EXAMPLE.COM
IPA_DOMAIN=example.com
CLIENT_IP_ADDR=192.168.19.20
CLIENT_FQDN=`hostname`
CLIENT_NAME=`hostname | cut -d. -f 1 | tr '[:upper:]' '[:lower:]'`
PASSWORD=aaaAAA111
