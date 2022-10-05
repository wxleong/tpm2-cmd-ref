#!/usr/bin/env bash
set -exo pipefail

#export TPM2TSSENGINE_TCTI="mssim:host=localhost,port=2321"

touch ~/.rnd

# Generate CSR
openssl req -new -provider tpm2 -key handle:0x81000001 -subj "/CN=TPM/O=Infineon/C=SG" -out tpm.csr

# Generate CA signed client cert
rm -rf ca 2> /dev/null
mkdir ca 2> /dev/null
touch ca/index.txt
touch ca/index.txt.attr
echo 'unique_subject = no' >> ca/index.txt.attr
echo '01' > ca/serial
(yes || true) | openssl ca -config config -in tpm.csr -out tpm.crt

# Read cert
#openssl x509 -in tpm.crt -text -noout

