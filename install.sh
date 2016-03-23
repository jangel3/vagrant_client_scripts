#! /bin/bash

set -e
set -x

echo "Exporting env variables"
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/config.sh

echo "Configuring /etc/hosts ..."
echo "127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1 	localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "$CLIENT_IP_ADDR    $CLIENT_FQDN $CLIENT_NAME" >> /etc/hosts

echo "Configuring /etc/resolv.conf"
echo "search $IPA_DOMAIN" > /etc/resolv.conf
echo "nameserver $SERVER_IP_ADDR" >> /etc/resolv.conf

echo "Disabling updates-testing repo ..."
sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-testing.repo

echo "Downloading packages ..."
yum install freeipa-client freeipa-admintools httpd mod_auth_kerb -y

echo "Configuring firewalld ..."
firewall-cmd --permanent --zone=public --add-port  80/tcp
firewall-cmd --permanent --zone=public --add-port 443/tcp
firewall-cmd --permanent --zone=public --add-port 389/tcp
firewall-cmd --permanent --zone=public --add-port 636/tcp
firewall-cmd --permanent --zone=public --add-port  88/tcp
firewall-cmd --permanent --zone=public --add-port 464/tcp
firewall-cmd --permanent --zone=public --add-port  53/tcp
firewall-cmd --permanent --zone=public --add-port  88/udp
firewall-cmd --permanent --zone=public --add-port 464/udp
firewall-cmd --permanent --zone=public --add-port  53/udp
firewall-cmd --permanent --zone=public --add-port 123/udp

firewall-cmd --zone=public --add-port  80/tcp
firewall-cmd --zone=public --add-port 443/tcp
firewall-cmd --zone=public --add-port 389/tcp
firewall-cmd --zone=public --add-port 636/tcp
firewall-cmd --zone=public --add-port  88/tcp
firewall-cmd --zone=public --add-port 464/tcp
firewall-cmd --zone=public --add-port  53/tcp
firewall-cmd --zone=public --add-port  88/udp
firewall-cmd --zone=public --add-port 464/udp
firewall-cmd --zone=public --add-port  53/udp
firewall-cmd --zone=public --add-port 123/udp

firewall-cmd --set-default-zone=public

echo "Setting up IP address ..."
mv /etc/sysconfig/network-scripts/ifcfg-enp0s3 /etc/sysconfig/network-scripts/enp0s3 # Somehow the initial ifcfg is wrong.  Just deactivate it
systemctl start network
sleep 5
ip addr add $CLIENT_IP_ADDR/24 dev enp0s8 # Add ip address.
sleep 5
echo "$SERVER_IP_ADDR    $SERVER_FQDN $SERVER_NAME" >> /etc/hosts

echo "Installing IPA client ..."
ipa-client-install --enable-dns-updates --ssh-trust-dns --domain=domain.local --server=ipaserver.domain.local -p admin -w $PASSWORD -U
 
echo "Testing kinit"
echo $PASSWORD | kinit admin

echo "Enrolling Apache as a service on the IPA Server"
ipa service-add HTTP/$CLIENT_FQDN

echo "Getting keytab from IPA Server to Client"
ipa-getkeytab -s $SERVER_FQDN -p HTTP/$CLIENT_FQDN -k /etc/httpd/http.keytab

echo "Changing ownership of keytab"
chown apache:apache /etc/httpd/http.keytab

echo "Testing Apache keytab"
kinit -kt /etc/httpd/http.keytab -p HTTP/$CLIENT_FQDN

echo "Re-kiniting as admin"
echo $PASSWORD | kinit admin
