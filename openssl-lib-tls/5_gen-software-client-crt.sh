#!/bin/sh -x

touch ~/.rnd

# Generate CSR
openssl req -new -key software.key -subj "/CN=Software/O=Infineon/C=SG" -out software.csr

# Generate CA signed client cert
mkdir ca >/dev/null 2>&1
rm ca/*
touch ca/index.txt
touch ca/index.txt.attr
echo '01' > ca/serial
yes | openssl ca -config config -in software.csr -out software.crt

# Read cert
#openssl x509 -in software.crt -text -noout

