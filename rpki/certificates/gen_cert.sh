#!/bin/bash

# Generate root certificate used for issuing other certificates
openssl req -new \
            -x509 \
            -newkey rsa:4096 \
            -sha256 \
            -nodes \
            -keyout root.key \
            -out root.crt \
            -days 365 \
            -subj "/C=IT/L=Roma/O=Tor Vergata"

# Prepare x509 Certificate extensions
{
            echo "[krill]"
            echo "subjectAltName=DNS:rpki-server.org, DNS:rpki-server.org:3000, DNS:rpki-server.org:80, DNS:localhost, IP:172.17.0.2, IP:127.0.0.1"
            echo "basicConstraints=CA:FALSE"
} >> krill.ext
openssl req -new \
            -newkey rsa:4096 \
            -keyout krill.key \
            -out krill.csr \
            -sha256 \
            -nodes \
            -days 365 \
            -subj "/C=IT/L=Roma/O=Tor Vergata/CN=rpki-server.org"
openssl x509 \
            -in krill.csr \
            -req \
            -out krill.crt \
            -CA root.crt \
            -CAkey root.key \
            -CAcreateserial \
            -extensions krill \
            -extfile krill.ext \
            -days 365

cat krill.crt krill.key > krill.includesprivatekey.pem

# Copy certs in appropriate folders
for folder in $(find ../ -type d -name '*r1')
do

            mkdir -p "${folder}/usr/local/share/ca-certificates/"
            mkdir -p "${folder}/etc/ssl/certs/"
            cp root.crt "${folder}/usr/local/share/ca-certificates/root.crt"
            cp krill.includesprivatekey.pem "${folder}/etc/ssl/certs/cert.includesprivatekey.pem"
done

mkdir -p "../krill/usr/local/share/ca-certificates/"
mkdir -p "../krill/etc/ssl/certs/"
mkdir -p "../krill/var/krill/data/ssl/"
cp root.crt "../krill/usr/local/share/ca-certificates/root.crt"
cp krill.includesprivatekey.pem "../krill/etc/ssl/certs/cert.includesprivatekey.pem"
cp krill.crt "../krill/var/krill/data/ssl/cert.pem"
cp krill.key "../krill/var/krill/data/ssl/key.pem"
