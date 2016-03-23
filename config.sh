#! /bin/bash

set -e
set -x

hostnamectl set-hostname --static "client.domain.local"
SERVER_IP_ADDR=192.168.56.101
SERVER_FQDN=ipaserver.domain.local
SERVER_NAME=ipaserver
IPA_REALM=DOMAIN.LOCAL
IPA_DOMAIN=domain.local
CLIENT_IP_ADDR=192.168.56.102
CLIENT_FQDN=`hostname`
CLIENT_NAME=`hostname | cut -d. -f 1 | tr '[:upper:]' '[:lower:]'`
PASSWORD=aaaAAA111
