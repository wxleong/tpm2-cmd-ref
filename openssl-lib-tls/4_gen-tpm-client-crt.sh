#!/bin/sh -x

export TPM2TSSENGINE_TCTI="mssim:host=localhost,port=2321"

touch ~/.rnd

# Generate CSR
openssl req -new -engine tpm2tss -keyform engine -key 0x81000001 -subj "/CN=TPM/O=Infineon/C=SG" -out tpm.csr

# Generate CA signed client cert
mkdir ca >/dev/null 2>&1
rm ca/*
touch ca/index.txt
touch ca/index.txt.attr
echo '01' > ca/serial
yes | openssl ca -config config -in tpm.csr -out tpm.crt

# Read cert
#openssl x509 -in tpm.crt -text -noout

