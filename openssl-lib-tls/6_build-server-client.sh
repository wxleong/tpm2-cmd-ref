#!/bin/sh -x

gcc -Wall -o server server.c -lssl -lcrypto
gcc -Wall -o client-software client.c -lssl -lcrypto
gcc -Wall -o client-tpm client.c -lssl -lcrypto -DENABLE_TPM_TSS_ENGINE

