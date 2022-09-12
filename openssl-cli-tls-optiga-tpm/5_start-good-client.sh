#!/bin/sh -x

unset TPM2TSSENGINE_TCTI

#
# CAfile: A file containing trusted certificates to use during server authentication 
# cert: Client certificate
# key: Client private key
#
echo "Q" | openssl s_client -engine tpm2tss -keyform engine -key 0x81000001 -cert tpm.crt -CAfile local-ca.crt -connect localhost:8443 -verify_return_error -quiet -no_ign_eof

