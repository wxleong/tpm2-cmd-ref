# Introduction

OPTIGA™ TPM 2.0 command reference and code examples.

# Table of Contents

- **[Prerequisites](#prerequisites)**
- **[Setup](#setup)**
- **[Using Hardware TPM](#using-hardware-tpm)**
- **[Behaviour of Microsoft TPM2.0 Simulator](#behaviour-of-microsoft-tpm20-simulator)**
- **[Examples](#examples)**
    - **[Audit](#audit)**
    - **[Certify](#certify)**
    - **[Clock & Time](#clock--time)**
    - **[Create Keys](#create-keys)**
    - **[Dictionary Attack Protection](#dictionary-attack-protection)**
	- **[Display TPM Capabilities](#display-tpm-capabilities)**
    - **[EK Credential](#ek-credential)**
    - **[Encrypted Session](#encrypted-session)**
    - **[Encryption & Decryption](#encryption--decryption)**
    - **[Get Random](#get-random)**
    - **[Hashing](#hashing)**
    - **[Hierarchy Control](#hierarchy-control)**
    - **[Import Externally Created key](#import-externally-created-key)**
        - **[Under a Parent Key](#under-a-parent-key)**
        - **[Under Hierarchy](#under-hierarchy)**
    - **[NV Storage](#nv-storage)**
    - **[OpenSSL CLI](#openssl-cli)**
        - **[PEM Encoded Key](#pem-encoded-key)**
            - **[Conversion to PEM Encoded Key](#conversion-to-pem-encoded-key)**
        - **[Persistent Key](#persistent-key-1)**
        - **[Nginx & Curl](#nginx--curl)**
            - **[PEM Encoded Key](#pem-encoded-key-1)**
            - **[Persistent Key](#persistent-key-2)**
    - **[OpenSSL Library](#openssl-library)**
        - **[General Examples](#general-examples)**
        - **[Server-client TLS Communication](#server-client-tls-communication)**
    - **[Password Authorization](#password-authorization)**
    - **[PCR](#pcr)**
    - **[Persistent Key](#persistent-key)**
    - **[PKCS #11](#pkcs-11)**
    - **[Quote](#quote)**
	- **[Read EK Certificate](#read-ek-certificate)**
    - **[Seal](#seal)**
    - **[Secure Key Transfer (Duplicate Key)](#secure-key-transfer-duplicate-key)**
        - **[Without Credential Protection](#without-credential-protection)**
        - **[With Credential Protection](#with-credential-protection)**
    - **[Self Test](#self-test)**
    - **[Session-based Authorization](#session-based-authorization)**
        - **[HMAC](#hmac)**
        - **[Policy](#policy)**
            - **[tpm2_policyauthorize](#tpm2_policyauthorize)**
            - **[tpm2_policyauthorizenv](#tpm2_policyauthorizenv)**
            - **[tpm2_policyauthvalue](#tpm2_policyauthvalue)**
            - **[tpm2_policycommandcode](#tpm2_policycommandcode)**
            - **[tpm2_policycountertimer](#tpm2_policycountertimer)**
            - **[tpm2_policycphash](#tpm2_policycphash)**
            - **[tpm2_policyduplicationselect](#tpm2_policyduplicationselect)**
            - **[tpm2_policylocality](#tpm2_policylocality)**
            - **[tpm2_policynamehash](#tpm2_policynamehash)**
            - **[tpm2_policynv](#tpm2_policynv)**
            - **[tpm2_policynvwritten](#tpm2_policynvwritten)**
            - **[tpm2_policyor](#tpm2_policyor)**
            - **[tpm2_policypassword](#tpm2_policypassword)**
            - **[tpm2_policypcr](#tpm2_policypcr)**
            - **[tpm2_policyrestart](#tpm2_policyrestart)**
            - **[tpm2_policysecret](#tpm2_policysecret)**
            - **[tpm2_policysigned](#tpm2_policysigned)**
            - **[tpm2_policytemplate](#tpm2_policytemplate)**
            - **[tpm2_policyticket](#tpm2_policyticket)**
    - **[Set Hierarchy Auth Value](#set-hierarchy-auth-value)**
    - **[Set Hierarchy Policy](#set-hierarchy-policy)**
    - **[Signing & Verification](#signing--verification)**
    - **[Startup](#startup)**
    - **[TPM Clear](#tpm-clear)**
- **[References](#references)**
- **[License](#license)**

# Prerequisites

- For simulated TPM 2.0, tested on: 
  ```
  $ lsb_release -a
  No LSB modules are available.
  Distributor ID:	Ubuntu
  Description:	Ubuntu 20.04.2 LTS
  Release:	20.04
  Codename:	focal

  $ uname -a
  Linux ubuntu 5.8.0-59-generic #66~20.04.1-Ubuntu SMP Thu Jun 17 11:14:10 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
  ```
- For hardware TPM 2.0, tested on Raspberry Pi 4 Model B with Iridium 9670 TPM 2.0 board [[10]](#10). For more details please visit [[8]](#8).

# Setup

Download package information:
```
$ sudo apt update
```

Install dependencies:
```
$ sudo apt -y install \
  autoconf-archive \
  libcmocka0 \
  libcmocka-dev \
  procps \
  iproute2 \
  build-essential \
  git \
  pkg-config \
  gcc \
  libtool \
  automake \
  libssl-dev \
  uthash-dev \
  autoconf \
  doxygen \
  libjson-c-dev \
  libini-config-dev \
  libcurl4-openssl-dev \
  python-yaml \
  uuid-dev \
  pandoc
```

Install tpm2-tss:
```
$ git clone https://github.com/tpm2-software/tpm2-tss ~/tpm2-tss
$ cd ~/tpm2-tss
$ git checkout 3.1.0
$ ./bootstrap
$ ./configure
$ make -j$(nproc)
$ sudo make install
$ sudo ldconfig
```

Install tpm2-tools:
```
$ git clone https://github.com/tpm2-software/tpm2-tools ~/tpm2-tools
$ cd ~/tpm2-tools
$ git checkout 5.2
$ ./bootstrap
$ ./configure
$ make -j$(nproc)
$ sudo make install
$ sudo ldconfig
```

Install tpm2-tss-engine:
```
$ git clone https://github.com/tpm2-software/tpm2-tss-engine ~/tpm2-tss-engine
$ cd ~/tpm2-tss-engine
$ git checkout v1.1.0
$ ./bootstrap
$ ./configure
$ make -j$(nproc)
$ sudo make install
$ sudo ldconfig
```

Install Microsoft TPM2.0 simulator:
```
$ git clone https://github.com/microsoft/ms-tpm-20-ref ~/ms-tpm-20-ref
$ cd ~/ms-tpm-20-ref/TPMCmd
$ ./bootstrap
$ ./configure
$ make -j$(nproc)
$ sudo make install
```

Test installation:
1. Start TPM simulator:
    ```
    $ cd ~
    $ tpm2-simulator
    LIBRARY_COMPATIBILITY_CHECK is ON
    Manufacturing NV state...
    Size of OBJECT = 1204
    Size of components in TPMT_SENSITIVE = 744
        TPMI_ALG_PUBLIC                 2
        TPM2B_AUTH                      50
        TPM2B_DIGEST                    50
        TPMU_SENSITIVE_COMPOSITE        642
    MAX_CONTEXT_SIZE can be reduced to 1264 (1344)
    TPM command server listening on port 2321
    Platform server listening on port 2322
    ```

2. Set TCTI to TPM simulator:
    ```
    # for tpm2-tools
    $ export TPM2TOOLS_TCTI="mssim:host=localhost,port=2321"
    
    # for tpm2-tss-engine
    $ export TPM2TSSENGINE_TCTI="mssim:host=localhost,port=2321"
    ```

3. Perform TPM startup:
    ```
    $ tpm2_startup -c
    ```

4. Get random:
    ```
    $ tpm2_getrandom --hex 16
    ```

# Using Hardware TPM

If you have hardware TPM enabled on your Linux platform (e.g., Raspberry Pi 4), set the TCTI to device node `tpm0` or `tpmrm0`:
```
$ export TPM2TOOLS_TCTI="device:/dev/tpmrm0"
$ export TPM2TSSENGINE_TCTI="device:/dev/tpmrm0"

# or

$ export TPM2TOOLS_TCTI="device:/dev/tpm0"
$ export TPM2TSSENGINE_TCTI="device:/dev/tpm0"
```

# Behaviour of Microsoft TPM2.0 Simulator

The Microsoft TPM2.0 simulator [[2]](#2) stores all persistent information in a file (`NVChip`). Find the file in the directory you launched the simulator. If you wish to start fresh, erase the file before launching the simulator.

Perform TPM startup after launching the simulator, otherwise, all subsequent commands will fail with the error code 0x100 (TPM not initialized by TPM2_Startup):
```
$ tpm2_startup -c
```

Keep an eye on the TPM transient and session memory:
```
$ tpm2_getcap handles-transient
$ tpm2_getcap handles-loaded-session
```

Once it hit 3 handles, the next command may fail with the error code 0x902 (out of memory for object contexts) / 0x903 (out of memory for session contexts). To clear the transient memory:
```
$ tpm2_flushcontext -t
$ tpm2_flushcontext -l
```

# Examples

## Audit

<ins><b>tpm2_getsessionauditdigest</b></ins>

Retrieve the session audit digest attestation data from the TPM. The attestation data includes the session audit digest and a signature over the session audit digest:

```
$ tpm2_createprimary -C e -g sha256 -G ecc -c primary_eh.ctx
$ tpm2_create -C primary_eh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv
$ tpm2_load -C primary_eh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_startauthsession -S session.ctx --audit-session
$ tpm2_getrandom 1 --hex -S session.ctx
$ tpm2_getsessionauditdigest -c signing.key.ctx -g sha256 -m attest.out -s signature.out -S session.ctx
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s signature.out
```

<!-- command not supported
<ins><b>tpm2_setcommandauditstatus</b></ins>

Add or remove TPM2 commands to the audited commands list.
-->

<!-- command not supported
<ins><b>tpm2_getcommandauditdigest</b></ins>

Retrieve the command audit attestation data from the TPM. The attestation data includes the audit digest of the commands in the setlist setup using the command `tpm2_setcommandauditstatus`. Also the attestation data includes the digest of the list of commands setup for audit. The audit digest algorith is setup in the `tpm2_setcommandauditstatus`.
       
tpm2_getcommandauditdigest -c signing.key.ctx -g sha256 -m attest.out -s signature.out
-->

## Certify

<ins><b>tpm2_certify</b></ins>

`tpm2_certify` proves that an object with a specific NAME is loaded in the TPM. By certifying that the object is loaded, the TPM warrants that a public area with a given Name is self consistent and associated with a valid sensitive area:
```
# Create a policy to restrict the usage of a signing key to only command TPM2_CC_Certify
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx -L policy.ctx TPM2_CC_Certify
$ tpm2_flushcontext session.ctx

# Create keys
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv -L policy.ctx -a "fixedtpm|fixedparent|sensitivedataorigin|adminwithpolicy|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_startauthsession  --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Certify
$ tpm2_certify -C signing.key.ctx -c primary_sh.ctx -p session:session.ctx -g sha256 -o attest.out -s signature.out
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s signature.out
```
The `attest.out` is:
- TPM2B_ATTEST ->
	- TPMS_ATTEST ->
		- TPMI_ST_ATTEST with the value of TPM_ST_ATTEST_CERTIFY, it determines the data type of TPMU_ATTEST 
		- TPMU_ATTEST ->
			- TPMS_CERTIFY_INFO ->
				- Qualified Name of the certified object

<!-- Needs TPM2_CertifyX509 but has not implemented in tpm2-tools yet
<ins><b>tpm2_certifyX509certutil</b></ins>

`tpm2_certifyX509certutil` generates a partial certificate that is suitable as the third input parameter for TPM2_certifyX509 command, however, TPM2_CertifyX509 is not implemented in tpm2-tools yet. 

The purpose of TPM2_CertifyX509 is to generate an X.509 certificate that proves an object with a specific public key and attributes is loaded in the TPM. In contrast to TPM2_Certify, which uses a TCG-defined data structure to convey attestation information (`attest.out`), TPM2_CertifyX509 encodes the attestation information in a DER-encoded X.509 certificate that is compliant with RFC5280 Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile.
-->

<ins><b>tpm2_certifycreation</b></ins>

When an object is created, the TPM creates a creation data that describes the environment in which the object was created. The TPM also produces a ticket that will allow the TPM to validate that the creation data was generated by the TPM. In other words, this allows the TPM to certify that it created the Object (TPM2_CertifyCreation()). This is most useful when fixedTPM is CLEAR in the created object. An example:

```
$ tpm2_createprimary -C o -g sha256 -G ecc --creation-data creation.data -d creation.data.hash -t creation.ticket -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv
$ tpm2_load -C primary_sh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_certifycreation -C signing.key.ctx -c primary_sh.ctx -d creation.data.hash -t creation.ticket -g sha256 -o signature.out --attestation attest.out

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s signature.out
```

Another example involving policy:
```
# Create a policy to restrict the usage of a signing key to only command TPM2_CC_CertifyCreation
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx -L policy.ctx TPM2_CC_CertifyCreation
$ tpm2_flushcontext session.ctx

$ tpm2_createprimary -C o -g sha256 -G ecc --creation-data creation.data -d creation.data.hash -t creation.ticket -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv -L policy.ctx -a "fixedtpm|fixedparent|sensitivedataorigin|adminwithpolicy|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_CertifyCreation
$ tpm2_certifycreation -C signing.key.ctx -P session:session.ctx -c primary_sh.ctx -d creation.data.hash -t creation.ticket -g sha256 -o signature.out --attestation attest.out
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s signature.out
```

<ins><b>tpm2_nvcertify</b></ins>

Provides attestation of the contents of an NV index. An example:

```
$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -s 32 -a "authread|authwrite"
$ tpm2_nvwrite 0x01000000 -i data

$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv -p key123
$ tpm2_load -C primary_sh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_nvcertify -C signing.key.ctx -P key123 -g sha256 -o signature.out --attestation attest.out --size 32 0x01000000
$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s signature.out

# or use OpenSSL to verify signature
$ tpm2_nvcertify -C signing.key.ctx -P key123 -g sha256 -f plain -o signature.out --attestation attest.out --size 32 0x01000000
$ tpm2_readpublic -c signing.key.ctx -o public.pem -f pem
$ openssl dgst -sha256 -verify public.pem -keyform pem -signature signature.out attest.out
```

Another example involving policy:
```
# Create a policy to restrict the usage of a signing key to only command TPM2_CC_CertifyCreation
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx -L policy.ctx TPM2_CC_NV_Certify
$ tpm2_flushcontext session.ctx

$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -s 32 -a "authread|authwrite"
$ tpm2_nvwrite 0x01000000 -i data

$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv -L policy.ctx -a "fixedtpm|fixedparent|sensitivedataorigin|adminwithpolicy|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_NV_Certify
$ tpm2_nvcertify -C signing.key.ctx -P session:session.ctx -g sha256 -o signature.out --attestation attest.out --size 32 0x01000000
$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s signature.out
$ tpm2_flushcontext session.ctx
```

# Clock & Time

<ins><b>tpm2_readclock</b></ins>

```
$ tpm2_readclock
  time: 12286
  clock_info:
    clock: 12286
    reset_count: 0
    restart_count: 0
    safe: yes
```

The command reads the current TPMS_TIME_INFO structure that contains the current setting of Time, Clock, Safe, resetCount, and restartCount:
- Reset count: This counter shall increment on each TPM Reset. This counter shall be reset to zero by TPM2_Clear(). A TPM Reset is either an unorderly shutdown or an orderly shutdown:
    ```
    $ tpm2_shutdown -c
    < cold/warm reset >
    $ tpm2_startup -c
    $ tpm2_readclock
    ```
- Restart count: This counter shall increment by one for each TPM Restart or TPM Resume. The restartCount shall be reset to zero on a TPM Reset or TPM2_Clear(). A TPM Restart is:
    ```
    $ tpm2_shutdown
    < cold/warm reset >
    $ tpm2_startup -c
    $ tpm2_readclock
    ```
    A TPM Resume is:
    ```
    $ tpm2_shutdown
    < cold/warm reset >
    $ tpm2_startup
    $ tpm2_readclock
    ```
- Clock: It is a time value in milliseconds that advances while the TPM is powered. The value shall be reset to zero by TPM2_Clear(). This value may be advanced by TPM2_ClockSet().

    Clock will be non-volatile but may have a volatile component that is updated every millisecond with the non-volatile component updated at a lower rate. The non-volatile component shall be updated no less frequently than every 222 milliseconds (~69.9 minutes). The update rate of the non-volatile portion of Clock shall be reported by command `tpm2_getcap properties-fixed` check property TPM_PT_CLOCK_UPDATE:
    ```
    $ tpm2_getcap properties-fixed
      ...
      TPM2_PT_CLOCK_UPDATE:
      raw: 0x40000 --> 262144ms -> 262s --> 4.4m
      ...
    ```
- Safe: This parameter is set to YES when the value reported in Clock is guaranteed to be greater than any previous value. This parameter will be set to YES by TPM2_Clear(). An unorderly shutdown will put the parameter to NO. After an unorderly shutdown, the parameter will return to YES when ((Clock % TPM2_PT_CLOCK_UPDATE) == 0).
- Time: It is a time value in milliseconds that advances while the TPM is powered. The value is reset whenever power to the time circuit is reestablished (in other words a cold reset).

<ins><b>tpm2_setclock</b></ins>

Sets the clock on the TPM to a time (milliseconds) in the future:
```
$ tpm2_readclock
  time: 5097
  clock_info:
    clock: 5097
    reset_count: 0
    restart_count: 0
    safe: yes
$ tpm2_setclock 10000
```

## Create Keys

Create primary key in platform hierarchy:
```
$ tpm2_createprimary -C p -g sha256 -G ecc -c primary_ph.ctx
```

Create primary key in storage hierarchy:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
```

Create ordinary keys:
```
# RSA
$ tpm2_create -C primary_sh.ctx -g sha256 -G rsa -u rsakey.pub -r rsakey.priv
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -c rsakey.ctx

# EC
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u eckey.pub -r eckey.priv
$ tpm2_load -C primary_sh.ctx -u eckey.pub -r eckey.priv -c eckey.ctx

# HMAC
$ tpm2_create -C primary_sh.ctx -G hmac -c hmackey.ctx
```
<!--

# AES
$ tpm2_create -C primary_sh.ctx -G aes256 -u aeskey.pub -r aeskey.priv
$ tpm2_load -C primary_sh.ctx -u aeskey.pub -r aeskey.priv -c aeskey.ctx

-->

## Dictionary Attack Protection

For practice, try this on simulator. Use hardware TPM at your own risk. 

Before we start, understand the basic:
- failedTries (TPM2_PT_LOCKOUT_COUNTER): Increment when an authorization failed or unorderly shutdown
- maxTries (TPM2_PT_MAX_AUTH_FAIL): In lockout mode when failedTries reaches this value
- recoveryTime (TPM2_PT_LOCKOUT_INTERVAL): This value indicates the rate at which failedTries is decremented in seconds
- lockoutRecovery (TPM2_PT_LOCKOUT_RECOVERY): This value indicates the retry delay in seconds after an authorization failure using lockout auth

Check the TPM lockout parameters:
```
$ tpm2_getcap properties-variable
```

Set lockout auth:
```
$ tpm2_changeauth -c l lockout123
```

Set lockout parameters to:
- maxTries = 5 tries
- recoveryTime = 10 seconds
- lockoutRecovery = 20 seconds
```
$ tpm2_dictionarylockout -s -n 5 -t 10 -l 20 -p lockout123
```

To trigger a lockout:
```
$ tpm2_createprimary -G ecc -c primary.ctx -p primary123
$ tpm2_create -G ecc -C primary.ctx -P badauth -u key.pub -r key.priv
WARNING:esys:src/tss2-esys/api/Esys_Create.c:398:Esys_Create_Finish() Received TPM Error 
ERROR:esys:src/tss2-esys/api/Esys_Create.c:134:Esys_Create() Esys Finish ErrorCode (0x0000098e) 
ERROR: Esys_Create(0x98E) - tpm:session(1):the authorization HMAC check failed and DA counter incremented
ERROR: Unable to run tpm2_create
$ tpm2_create -G ecc -C primary.ctx -P badauth -u key.pub -r key.priv
WARNING:esys:src/tss2-esys/api/Esys_Create.c:398:Esys_Create_Finish() Received TPM Error 
ERROR:esys:src/tss2-esys/api/Esys_Create.c:134:Esys_Create() Esys Finish ErrorCode (0x0000098e) 
ERROR: Esys_Create(0x98E) - tpm:session(1):the authorization HMAC check failed and DA counter incremented
ERROR: Unable to run tpm2_create
$ tpm2_create -G ecc -C primary.ctx -P badauth -u key.pub -r key.priv
WARNING:esys:src/tss2-esys/api/Esys_Create.c:398:Esys_Create_Finish() Received TPM Error 
ERROR:esys:src/tss2-esys/api/Esys_Create.c:134:Esys_Create() Esys Finish ErrorCode (0x0000098e) 
ERROR: Esys_Create(0x98E) - tpm:session(1):the authorization HMAC check failed and DA counter incremented
ERROR: Unable to run tpm2_create
$ tpm2_create -G ecc -C primary.ctx -P badauth -u key.pub -r key.priv
WARNING:esys:src/tss2-esys/api/Esys_Create.c:398:Esys_Create_Finish() Received TPM Error 
ERROR:esys:src/tss2-esys/api/Esys_Create.c:134:Esys_Create() Esys Finish ErrorCode (0x0000098e) 
ERROR: Esys_Create(0x98E) - tpm:session(1):the authorization HMAC check failed and DA counter incremented
ERROR: Unable to run tpm2_create
$ tpm2_create -G ecc -C primary.ctx -P badauth -u key.pub -r key.priv
WARNING:esys:src/tss2-esys/api/Esys_Create.c:398:Esys_Create_Finish() Received TPM Error 
ERROR:esys:src/tss2-esys/api/Esys_Create.c:134:Esys_Create() Esys Finish ErrorCode (0x00000921) 
ERROR: Esys_Create(0x921) - tpm:warn(2.0): authorizations for objects subject to DA protection are not allowed at this time because the TPM is in DA lockout mode
ERROR: Unable to run tpm2_create
```

To exit lockout state, wait for 10 seconds (recoveryTime) or use lockout auth:
```
$ tpm2_dictionarylockout -c -p lockout123
```

To trigger a lockout on the lockout auth:
```
$ tpm2_dictionarylockout -c -p badauth
```

Wait for 20 seconds (lockoutRecovery) before you can try again.

## Display TPM Capabilities

Return a list of supported capability names:
```
$ tpm2_getcap -l
- algorithms
- commands
- pcrs
- properties-fixed
- properties-variable
- ecc-curves
- handles-transient
- handles-persistent
- handles-permanent
- handles-pcr
- handles-nv-index
- handles-loaded-session
- handles-saved-session
```

Find TPM 2.0 library specification revision [[9]](#9) by:
```
$ tpm2_getcap properties-fixed
TPM2_PT_FAMILY_INDICATOR:
  raw: 0x322E3000
  value: "2.0"
TPM2_PT_LEVEL:
  raw: 0
TPM2_PT_REVISION:
  raw: 0x74
  value: 1.16 <----------- revision 1.16
TPM2_PT_DAY_OF_YEAR:
  raw: 0xF
TPM2_PT_YEAR:
  raw: 0x7E0
TPM2_PT_MANUFACTURER:
  raw: 0x49465800
  value: "IFX"
TPM2_PT_VENDOR_STRING_1:
  raw: 0x534C4239
  value: "SLB9"
TPM2_PT_VENDOR_STRING_2:
  raw: 0x36373000
  value: "670"
TPM2_PT_VENDOR_STRING_3:
  raw: 0x0
  value: ""
TPM2_PT_VENDOR_STRING_4:
  raw: 0x0
  value: ""
TPM2_PT_VENDOR_TPM_TYPE:
  raw: 0x0
TPM2_PT_FIRMWARE_VERSION_1:
  raw: 0x7003D
TPM2_PT_FIRMWARE_VERSION_2:
  raw: 0xAE100
TPM2_PT_INPUT_BUFFER:
  raw: 0x400
TPM2_PT_HR_TRANSIENT_MIN:
  raw: 0x3
TPM2_PT_HR_PERSISTENT_MIN:
  raw: 0x7
TPM2_PT_HR_LOADED_MIN:
  raw: 0x3
TPM2_PT_ACTIVE_SESSIONS_MAX:
  raw: 0x40
TPM2_PT_PCR_COUNT:
  raw: 0x18
TPM2_PT_PCR_SELECT_MIN:
  raw: 0x3
TPM2_PT_CONTEXT_GAP_MAX:
  raw: 0xFFFF
TPM2_PT_NV_COUNTERS_MAX:
  raw: 0x8
TPM2_PT_NV_INDEX_MAX:
  raw: 0x680
TPM2_PT_MEMORY:
  raw: 0x6
TPM2_PT_CLOCK_UPDATE:
  raw: 0x80000
TPM2_PT_CONTEXT_HASH:
  raw: 0xB
TPM2_PT_CONTEXT_SYM:
  raw: 0x6
TPM2_PT_CONTEXT_SYM_SIZE:
  raw: 0x80
TPM2_PT_ORDERLY_COUNT:
  raw: 0xFF
TPM2_PT_MAX_COMMAND_SIZE:
  raw: 0x500
TPM2_PT_MAX_RESPONSE_SIZE:
  raw: 0x500
TPM2_PT_MAX_DIGEST:
  raw: 0x20
TPM2_PT_MAX_OBJECT_CONTEXT:
  raw: 0x3B8
TPM2_PT_MAX_SESSION_CONTEXT:
  raw: 0xEB
TPM2_PT_PS_FAMILY_INDICATOR:
  raw: 0x1
TPM2_PT_PS_LEVEL:
  raw: 0x0
TPM2_PT_PS_REVISION:
  raw: 0x100
TPM2_PT_PS_DAY_OF_YEAR:
  raw: 0x0
TPM2_PT_PS_YEAR:
  raw: 0x0
TPM2_PT_SPLIT_MAX:
  raw: 0x80
TPM2_PT_TOTAL_COMMANDS:
  raw: 0x5A
TPM2_PT_LIBRARY_COMMANDS:
  raw: 0x59
TPM2_PT_VENDOR_COMMANDS:
  raw: 0x1
TPM2_PT_NV_BUFFER_MAX:
  raw: 0x300
```

Check what commands are supported:
```
$ tpm2_getcap commands
```

## EK Credential 

Create EK and AK:
```
$ tpm2_createek -c 0x81010001 -G rsa -u ek.pub
$ tpm2_createak -C 0x81010001 -c ak.ctx -u ak.pub -n ak.name
$ tpm2_evictcontrol -C o -c ak.ctx 0x81010002
$ tpm2_getcap handles-persistent
```

Make credential:
```
$ dd if=/dev/urandom of=data.clear bs=1 count=16
$ tpm2_makecredential -e ek.pub -s data.clear -n $(xxd -ps -c 100 ak.name) -o data.cipher
```

Activate credential:
```
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policysecret -S session.ctx -c e
$ tpm2_activatecredential -c 0x81010002 -C 0x81010001 -i data.cipher -o data.decipher -P session:session.ctx
$ tpm2_flushcontext session.ctx
$ diff data.decipher data.clear
```

## Encrypted Session

Using a HMAC session to enable encryption of selected parameters.

Get random:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_getrandom -S session.ctx --hex 16
$ tpm2_flushcontext session.ctx
```

Decryption:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ echo "some secret" > secret.clear
$ tpm2_rsaencrypt -c rsakey.ctx -o secret.cipher secret.clear

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_rsadecrypt -p session:session.ctx -c rsakey.ctx -o secret.decipher secret.cipher
$ tpm2_flushcontext session.ctx
```

Sign:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ echo "some message" > message

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_sign -p session:session.ctx -c rsakey.ctx -g sha256 -o signature message
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m message -s signature
```

HMAC:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ echo "some message" > message

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_hmac -p session:session.ctx -c hmackey.ctx --hex message
$ tpm2_flushcontext session.ctx
```

NV operations:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -C o -s 32 -a "ownerwrite|ownerread"

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_nvwrite 0x01000000 -P session:session.ctx -C o -i data
$ tpm2_nvread 0x01000000 -P session:session.ctx -C o -o out
$ tpm2_flushcontext session.ctx

$ tpm2_nvundefine 0x01000000 -C o
```

## Encryption & Decryption

Using RSA key:
```
$ echo "some secret" > secret.clear
$ tpm2_rsaencrypt -c rsakey.ctx -o secret.cipher secret.clear
$ tpm2_rsadecrypt -c rsakey.ctx -o secret.decipher secret.cipher
$ diff secret.decipher secret.clear

# or use OpenSSL to encrypt message

$ tpm2_readpublic -c rsakey.ctx -o public.pem -f pem
$ openssl rsautl -encrypt -inkey public.pem -in secret.clear -pubin -out secret.cipher
$ tpm2_rsadecrypt -c rsakey.ctx -o secret.decipher secret.cipher
$ diff secret.decipher secret.clear
```

<!--

Using AES key:
```
$ echo "some secret" > secret.clear
$ tpm2_getrandom 16 > iv
$ tpm2_encryptdecrypt -c aeskey.ctx -t iv -o secret.cipher secret.clear
$ tpm2_encryptdecrypt -d -c aeskey.ctx -t iv -o secret.decipher secret.cipher
$ diff secret.decipher secret.clear
```

-->

## Get Random

Get 16 bytes of random:
```
$ tpm2_getrandom --hex 16
```

## Hashing

```
$ echo "some message" > message
$ tpm2_hash -g sha256 --hex message
```

## Hierarchy Control

Disable/Enable storage hierarchy:
```
$ tpm2_hierarchycontrol -C o shEnable clear
$ tpm2_hierarchycontrol -C p shEnable set
```

Disable/Enable endorsement hierarchy:
```
$ tpm2_hierarchycontrol -C e ehEnable clear
$ tpm2_hierarchycontrol -C p ehEnable set
```

Disable platform hierarchy:
```
$ tpm2_hierarchycontrol -C p phEnable clear
```

phEnable, shEnable, and ehEnable flag is not persistent. All hierarchies will be set to TRUE after a reset.

To simulate a reset (power cycling) simply terminate and relaunch the simulator, remember to run `tpm2_startup -c`.

View hierarchy information:
```
$ tpm2_getcap properties-variable
```

## Import Externally Created key

### Under a Parent Key

RSA key:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ openssl genrsa -out rsa_private.pem 2048
$ tpm2_import -C primary_sh.ctx -G rsa -i rsa_private.pem -u rsakey_imported.pub -r rsakey_imported.priv
$ tpm2_load -C primary_sh.ctx -u rsakey_imported.pub -r rsakey_imported.priv -c rsakey_imported.ctx
```

EC key:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ openssl ecparam -name prime256v1 -genkey -noout -out ecc_private.pem
$ tpm2_import -C primary_sh.ctx -G ecc -i ecc_private.pem -u eckey_imported.pub -r eckey_imported.priv
$ tpm2_load -C primary_sh.ctx -u eckey_imported.pub -r eckey_imported.priv -c eckey_imported.ctx
```

HMAC key:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ dd if=/dev/urandom of=raw.key bs=1 count=32
$ tpm2_import -C primary_sh.ctx -G hmac -i raw.key -u hmackey_imported.pub -r hmackey_imported.priv
$ tpm2_load -C primary_sh.ctx -u hmackey_imported.pub -r hmackey_imported.priv -c hmackey_imported.ctx
```

### Under Hierarchy

Load of a public external object area allows the object to be associated with a hierarchy. If the public and sensitive portions of the object are loaded, hierarchy is required to be TPM_RH_NULL.

RSA key to null hierarchy:
```
$ openssl genrsa -out rsa_private.pem 2048
$ tpm2_loadexternal -C n -G rsa -r rsa_private.pem -c rsakey_imported.ctx
```

EC key to null hierarchy:
```
$ openssl ecparam -name prime256v1 -genkey -noout -out ecc_private.pem
$ tpm2_loadexternal -C n -G ecc -r ecc_private.pem -c eckey_imported.ctx
```

Just the public component of an RSA key to storage hierarchy:
```
$ openssl genrsa -out rsa_private.pem 2048
$ openssl rsa -in rsa_private.pem -out rsa_public.pem -pubout
$ tpm2_loadexternal -C o -G rsa -u rsa_public.pem -c rsakey_imported.ctx
```

## NV Storage

NV define, write, and read:
```
$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -C o -s 32 -a "ownerwrite|ownerread"
$ tpm2_nvwrite 0x01000000 -C o -i data
$ tpm2_nvread 0x01000000 -C o -o out
$ diff data out
```

NV read public:
```
$ tpm2_nvreadpublic
```

Read NV indices:
```
$ tpm2_getcap handles-nv-index
```

NV undefine:
```
$ tpm2_nvundefine 0x01000000 -C o
```

NV with auth value protection:
```
$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -C o -s 32 -a "authread|authwrite" -p pswd
$ tpm2_nvwrite 0x01000000 -i data -P pswd
$ tpm2_nvread 0x01000000 -o out -P pswd
$ diff data out
$ tpm2_nvundefine 0x01000000 -C o
```

NV under platform hierarchy. In this mode, the NV index cannot be cleared by `tpm2_clear`:
```
$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -C p -s 32 -a "ppwrite|ppread|platformcreate"
$ tpm2_nvwrite 0x01000000 -C p -i data
$ tpm2_nvread 0x01000000 -C p -o out
$ diff data out
$ tpm2_nvundefine 0x01000000 -C p
```

Define a 64-bit NV for OR operation:
```
$ tpm2_nvdefine 0x01000000 -C o -a "nt=bits|ownerwrite|ownerread"

# OR 1's into NV index
$ tpm2_nvsetbits 0x01000000 -C o -i 0x1111111111111111
$ tpm2_nvread 0x01000000 -C o | xxd -p

$ tpm2_nvundefine 0x01000000 -C o
```

Define a 64-bit NV for counting operation:
```
$ tpm2_nvdefine 0x01000000 -C o -a "nt=counter|ownerwrite|ownerread"

# increment
$ tpm2_nvincrement 0x01000000 -C o
$ tpm2_nvread 0x01000000 -C o | xxd -p

$ tpm2_nvundefine 0x01000000 -C o
```

Define a 64-bit NV for extend operation. The name algorithm decides the hash algorithm used for the extend:
```
$ tpm2_nvdefine 0x01000000 -C o -g sha256 -a "nt=extend|ownerwrite|ownerread"

# extend
$ echo "plaintext" > plain.txt
$ tpm2_nvextend 0x01000000 -C o -i plain.txt
$ tpm2_nvread 0x01000000 -C o | xxd -c 32 -p

$ tpm2_nvundefine 0x01000000 -C o
```

Define an NV for pinfail operation:
<!-- Use `tpm2_nvread 0x01000000 -C o` to read the NV instead of `tpm2_nvread 0x01000000 -C 0x01000000 -P pass123`, because a successful authentication using index authvalue will reset the pinCount -->
<!-- If TPM_NT is TPM_NT_PIN_FAIL, TPMA_NV_NO_DA must be SET. This removes ambiguity over which Dictionary Attack defense protects a TPM_NV_PIN_FAIL's authValue. -->
<!-- TPMA_NV_AUTHWRITE must set to CLEAR. For reasoning purpose: imagine if TPMA_NV_AUTHWRITE was SET for a pinpass/pinfail, a user knowing the authorization value could decrease pinCount or increase pinLimit, defeating the purpose of a pinfail/pinfail. -->
<!-- pinCount is incremented after an authorization attempt using authValue succeeds -->
```
$ tpm2_nvdefine 0x01000000 -C o -a "nt=pinfail|ownerwrite|ownerread|authread|no_da" -p pass123

# set the TPMS_NV_PIN_COUNTER_PARAMETERS structure (pinCount=0|pinLimit=5)
$ echo -n -e '\x00\x00\x00\x00\x00\x00\x00\x05' > data
$ tpm2_nvwrite 0x01000000 -C o -i data
$ tpm2_nvread 0x01000000 -C o | xxd -p

# trigger localized dictionary attack protection
$ tpm2_nvread 0x01000000 -C 0x01000000 -P pass123 | xxd -p
$ tpm2_nvread 0x01000000 -C 0x01000000 -P fail123 <---- expected to fail
$ tpm2_nvread 0x01000000 -C o | xxd -p            <---- notice pinCount increases by 1
$ tpm2_nvread 0x01000000 -C 0x01000000 -P fail123
$ tpm2_nvread 0x01000000 -C 0x01000000 -P fail123
$ tpm2_nvread 0x01000000 -C 0x01000000 -P fail123
$ tpm2_nvread 0x01000000 -C 0x01000000 -P fail123
$ tpm2_nvread 0x01000000 -C 0x01000000 -P fail123 <---- authorization via authValue is now locked out 

# exit authValue lockout
$ tpm2_nvwrite 0x01000000 -C o -i data

$ tpm2_nvundefine 0x01000000 -C o
```

A more meaningful pinfail example:
```
$ tpm2_nvdefine 0x01000000 -C o -a "nt=pinfail|ownerwrite|ownerread|authread|no_da" -p pass123

# set the TPMS_NV_PIN_COUNTER_PARAMETERS structure (pinCount=0|pinLimit=5)
$ echo -n -e '\x00\x00\x00\x00\x00\x00\x00\x05' > data
$ tpm2_nvwrite 0x01000000 -C o -i data
$ tpm2_nvread 0x01000000 -C o | xxd -p

# create a policy to use nv auth for authorization
$ tpm2_startauthsession -S session.ctx
$ tpm2_policysecret -S session.ctx -L secret.policy -c 0x01000000 pass123
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L secret.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policysecret -S session.ctx -c 0x01000000 pass123
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

# trigger localized dictionary attack protection
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policysecret -S session.ctx -c 0x01000000 fail123 <---- expected to fail
$ tpm2_nvread 0x01000000 -C o | xxd -p                   <---- notice pinCount increases by 1
$ tpm2_policysecret -S session.ctx -c 0x01000000 fail123
$ tpm2_policysecret -S session.ctx -c 0x01000000 fail123
$ tpm2_policysecret -S session.ctx -c 0x01000000 fail123
$ tpm2_policysecret -S session.ctx -c 0x01000000 fail123 <---- notice pinCount == pinLimit
$ tpm2_policysecret -S session.ctx -c 0x01000000 fail123 <---- authorization using authValue will fail
$ tpm2_flushcontext session.ctx

# re-enable NV authValue
$ tpm2_nvwrite 0x01000000 -C o -i data

$ tpm2_nvundefine 0x01000000 -C o
```

Define an NV for pinpass operation:
<!-- Use `tpm2_nvread 0x01000000 -C o` to read the NV instead of `tpm2_nvread 0x01000000 -C 0x01000000 -P pass123`, because a successful authentication using index authvalue will increase the pinCount -->
<!-- TPMA_NV_AUTHWRITE must set to CLEAR. For reasoning purpose: imagine if TPMA_NV_AUTHWRITE was SET for a pinpass/pinfail, a user knowing the authorization value could decrease pinCount or increase pinLimit, defeating the purpose of a pinfail/pinfail. -->
<!-- pinCount is incremented after an authorization attempt using authValue fails -->
```
$ tpm2_nvdefine 0x01000000 -C o -a "nt=pinpass|ownerwrite|ownerread|authread" -p pass123

# set the TPMS_NV_PIN_COUNTER_PARAMETERS structure (pinCount=0|pinLimit=5)
$ echo -n -e '\x00\x00\x00\x00\x00\x00\x00\x05' > data
$ tpm2_nvwrite 0x01000000 -C o -i data
$ tpm2_nvread 0x01000000 -C o | xxd -p

# restricting the number of uses with pinpass
$ tpm2_nvread 0x01000000 -C 0x01000000 -P pass123 | xxd -p  <---- notice pinCount increases by 1
$ tpm2_nvread 0x01000000 -C 0x01000000 -P pass123 | xxd -p
$ tpm2_nvread 0x01000000 -C 0x01000000 -P pass123 | xxd -p
$ tpm2_nvread 0x01000000 -C 0x01000000 -P pass123 | xxd -p
$ tpm2_nvread 0x01000000 -C 0x01000000 -P pass123 | xxd -p  <---- notice pinCount == pinLimit
$ tpm2_nvread 0x01000000 -C 0x01000000 -P pass123 | xxd -p  <---- authorization using authValue will fail 

# re-enable NV authValue
$ tpm2_nvwrite 0x01000000 -C o -i data

$ tpm2_nvundefine 0x01000000 -C o
```

A more meaningful pinpass example:
```
$ tpm2_nvdefine 0x01000000 -C o -a "nt=pinpass|ownerwrite|ownerread|authread" -p pass123

# set the TPMS_NV_PIN_COUNTER_PARAMETERS structure (pinCount=0|pinLimit=5)
$ echo -n -e '\x00\x00\x00\x00\x00\x00\x00\x05' > data
$ tpm2_nvwrite 0x01000000 -C o -i data
$ tpm2_nvread 0x01000000 -C o | xxd -p

# create a policy to use nv auth for authorization
$ tpm2_startauthsession -S session.ctx
$ tpm2_policysecret -S session.ctx -L secret.policy -c 0x01000000 pass123
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L secret.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policysecret -S session.ctx -c 0x01000000 pass123
$ tpm2_nvread 0x01000000 -C o | xxd -p                   <---- notice pinCount increases by 1
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

# restricting the number of uses of an object with pinpass
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policysecret -S session.ctx -c 0x01000000 pass123 
$ tpm2_nvread 0x01000000 -C o | xxd -p                   <---- notice pinCount increases by 1
$ tpm2_policysecret -S session.ctx -c 0x01000000 pass123
$ tpm2_policysecret -S session.ctx -c 0x01000000 pass123
$ tpm2_policysecret -S session.ctx -c 0x01000000 pass123
$ tpm2_nvread 0x01000000 -C o | xxd -p                   <---- notice pinCount == pinLimit
$ tpm2_policysecret -S session.ctx -c 0x01000000 pass123 <---- authorization using authValue will fail
$ tpm2_flushcontext session.ctx

# re-enable NV authValue
$ tpm2_nvwrite 0x01000000 -C o -i data

$ tpm2_nvundefine 0x01000000 -C o
```

## OpenSSL CLI

Verify TPM engine (tpm2-tss-engine) installation:
```
$ openssl engine -t -c tpm2tss
(tpm2tss) TPM2-TSS engine for OpenSSL
 [RSA, RAND]
     [ available ]
```

Generate random value:
```
$ openssl rand -engine tpm2tss -hex 10
```

### PEM Encoded Key

Create RSA key using tpm2-tss-engine tool, the output is a PEM encoded TPM key object:
```
$ tpm2tss-genkey -P 0x81000001 -a rsa -s 2048 rsakey.pem

# or

$ tpm2_clear -c p
$ tpm2tss-genkey -a rsa -s 2048 rsakey.pem
```

Create EC key using tpm2-tss-engine tool:
```
$ tpm2tss-genkey -P 0x81000001 -a ecdsa eckey.pem

# or

$ tpm2_clear -c p
$ tpm2tss-genkey -a ecdsa eckey.pem
```

Read public component:
```
$ openssl rsa -engine tpm2tss -inform engine -in rsakey.pem -pubout -outform pem -out rsakey.pub.pem
$ openssl ec -engine tpm2tss -inform engine -in eckey.pem -pubout -outform pem -out eckey.pub.pem
```

RSA encryption & decryption:
```
$ echo "some secret" > secret.clear
$ openssl pkeyutl -pubin -inkey rsakey.pub.pem -in secret.clear -encrypt -out secret.cipher
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey rsakey.pem -decrypt -in secret.cipher -out secret.decipher
$ diff secret.clear secret.decipher
```

RSA signing & verification:
```
$ dd bs=1 count=32 </dev/urandom > data
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey rsakey.pem -sign -in data -out data.sig
$ openssl pkeyutl -pubin -inkey rsakey.pub.pem -verify -in data -sigfile data.sig
```

EC signing & verification:
```
$ dd bs=1 count=32 </dev/urandom > data
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey eckey.pem -sign -in data -out data.sig
$ openssl pkeyutl -pubin -inkey eckey.pub.pem -verify -in data -sigfile data.sig
```

Create self-signed certificate:
```
$ openssl req -new -x509 -engine tpm2tss -keyform engine -key rsakey.pem -subj "/CN=TPM/O=Infineon/C=SG" -out rsakey.crt.pem
$ openssl x509 -in rsakey.crt.pem -text -noout
$ openssl req -new -x509 -engine tpm2tss -keyform engine -key eckey.pem -subj "/CN=TPM/O=Infineon/C=SG" -out eckey.crt.pem
$ openssl x509 -in eckey.crt.pem -text -noout
```

Create certificate signing request (CSR):
```
$ openssl req -new -engine tpm2tss -keyform engine -key rsakey.pem -subj "/CN=TPM/O=Infineon/C=SG" -out rsakey.csr.pem
$ openssl req -in rsakey.csr.pem -text -noout
$ openssl req -new -engine tpm2tss -keyform engine -key eckey.pem -subj "/CN=TPM/O=Infineon/C=SG" -out eckey.csr.pem
$ openssl req -in eckey.csr.pem -text -noout
```

#### Conversion to PEM Encoded Key

In the event that TPM key is not created using `tpm2tss-genkey`, use the following tool to make the conversion.

Build tool:
```
$ cd openssl-lib-convert-to-pem-key
$ gcc -Wall -o convert convert.c -lcrypto -ltss2-mu -L /usr/lib/x86_64-linux-gnu/engines-1.1 -ltpm2tss
```

RSA key:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_evictcontrol -C o -c primary_sh.ctx 0x81000001
$ tpm2_create -C 0x81000001 -g sha256 -G rsa -u rsakey.pub -r rsakey.priv -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign|noda"

$ export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/engines-1.1
$ ./convert 0x81000001 rsakey.pub rsakey.priv rsakey.pem

# quick verification
$ dd bs=1 count=32 </dev/urandom > data
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey rsakey.pem -sign -in data -out data.sig
$ openssl rsa -engine tpm2tss -inform engine -in rsakey.pem -pubout -outform pem -out rsakey.pub.pem
$ openssl pkeyutl -pubin -inkey rsakey.pub.pem -verify -in data -sigfile data.sig
```

EC key:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_evictcontrol -C o -c primary_sh.ctx 0x81000001
$ tpm2_create -C 0x81000001 -g sha256 -G ecc -u eckey.pub -r eckey.priv -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|sign|noda"

$ export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/engines-1.1
$ ./convert 0x81000001 eckey.pub eckey.priv eckey.pem

# quick verification
$ dd bs=1 count=32 </dev/urandom > data
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey eckey.pem -sign -in data -out data.sig
$ openssl ec -engine tpm2tss -inform engine -in eckey.pem -pubout -outform pem -out eckey.pub.pem
$ openssl pkeyutl -pubin -inkey eckey.pub.pem -verify -in data -sigfile data.sig
```

### Persistent Key

Generate persistent RSA and EC keys using tpm2-tools:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ tpm2_create -C primary_sh.ctx -g sha256 -G rsa -u rsakey.pub -r rsakey.priv -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign|noda"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -c rsakey.ctx
$ tpm2_evictcontrol -C o -c rsakey.ctx 0x81000002

$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u eckey.pub -r eckey.priv -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|sign|noda"
$ tpm2_load -C primary_sh.ctx -u eckey.pub -r eckey.priv -c eckey.ctx
$ tpm2_evictcontrol -C o -c eckey.ctx 0x81000003
```

Read public component:
```
$ openssl rsa -engine tpm2tss -inform engine -in 0x81000002 -pubout -outform pem -out rsakey.pub.pem
$ openssl ec -engine tpm2tss -inform engine -in 0x81000003 -pubout -outform pem -out eckey.pub.pem
```

RSA encryption & decryption:
```
$ echo "some secret" > secret.clear
$ openssl pkeyutl -pubin -inkey rsakey.pub.pem -in secret.clear -encrypt -out secret.cipher
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey 0x81000002 -decrypt -in secret.cipher -out secret.decipher
$ diff secret.clear secret.decipher
```

RSA signing & verification:
```
$ dd bs=1 count=32 </dev/urandom > data
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey 0x81000002 -sign -in data -out data.sig
$ openssl pkeyutl -pubin -inkey rsakey.pub.pem -verify -in data -sigfile data.sig
```

EC signing & verification:
```
$ dd bs=1 count=32 </dev/urandom > data
$ openssl pkeyutl -engine tpm2tss -keyform engine -inkey 0x81000003 -sign -in data -out data.sig
$ openssl pkeyutl -pubin -inkey eckey.pub.pem -verify -in data -sigfile data.sig
```

Create self-signed certificate:
```
$ openssl req -new -x509 -engine tpm2tss -keyform engine -key 0x81000002 -subj "/CN=TPM/O=Infineon/C=SG" -out rsakey.crt.pem
$ openssl x509 -in rsakey.crt.pem -text -noout
$ openssl req -new -x509 -engine tpm2tss -keyform engine -key 0x81000003 -subj "/CN=TPM/O=Infineon/C=SG" -out eckey.crt.pem
$ openssl x509 -in eckey.crt.pem -text -noout
```

Create certificate signing request (CSR):
```
$ openssl req -new -engine tpm2tss -keyform engine -key 0x81000002 -subj "/CN=TPM/O=Infineon/C=SG" -out rsakey.csr.pem
$ openssl req -in rsakey.csr.pem -text -noout
$ openssl req -new -engine tpm2tss -keyform engine -key 0x81000003 -subj "/CN=TPM/O=Infineon/C=SG" -out eckey.csr.pem
$ openssl req -in eckey.csr.pem -text -noout
```

### Nginx & Curl

Install Nginx on your host:
```
$ sudo apt install nginx
```

Add `ssl_engine tpm2tss;` to `/etc/nginx/nginx.conf`, check reference [nginx/nginx.conf](nginx/nginx.conf)

#### PEM Encoded Key

Create key & self-signed certificate:
```
$ cd /tmp
$ tpm2tss-genkey -a rsa -s 2048 rsakey.pem
$ openssl req -new -x509 -engine tpm2tss -keyform engine -key rsakey.pem -subj "/CN=TPM/O=Infineon/C=SG" -out rsakey.crt.pem
```

Edit `/etc/nginx/sites-enabled/default` to enable SSL, check reference [nginx/default-pem](nginx/default-pem)

Restart Nginx:
```
$ sudo service nginx restart
```

Using Curl to test the connection:
```
$ curl --insecure --engine tpm2tss --key-type ENG --key rsakey.pem --cert rsakey.crt.pem https://127.0.0.1
```

#### Persistent Key

Create key & self-signed certificate:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G rsa -u rsakey.pub -r rsakey.priv -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign|noda"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -c rsakey.ctx
$ tpm2_evictcontrol -C o -c rsakey.ctx 0x81000002
$ openssl req -new -x509 -engine tpm2tss -keyform engine -key 0x81000002 -subj "/CN=TPM/O=Infineon/C=SG" -out rsakey.crt.pem
```

Edit `/etc/nginx/sites-enabled/default` to enable SSL, check reference [nginx/default-persistent](nginx/default-persistent)

Restart Nginx:
```
$ sudo service nginx restart
```

Using Curl to test the connection:
```
$ curl --insecure --engine tpm2tss --key-type ENG --key 0x81000002 --cert rsakey.crt.pem https://127.0.0.1
```

## OpenSSL Library

### General Examples

- Get random
- RSA/EC key creation
- RSA encryption/decryption/sign/verification
- EC sign/verification

```
$ cd openssl-lib-general-examples
$ gcc -Wall -o examples examples.c -lssl -lcrypto -L /usr/lib/x86_64-linux-gnu/engines-1.1 -ltpm2tss
$ export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/engines-1.1
$ ./examples
```

### Server-client TLS Communication

```
$ cd openssl-lib-tls
$ chmod a+x *.sh
$ ./0_clean-up.sh 
$ ./1_init-tpm-key.sh 
$ ./2_init-software-key.sh 
$ ./3_gen-ca-crt.sh 
$ ./4_gen-tpm-client-crt.sh 
$ ./5_gen-software-client-crt.sh 
$ ./6_build-server-client.sh 
$ ./7_start-server.sh 

# start a new terminal
$ cd openssl-lib-tls
$ ./8_start-software-client.sh
$ ./9_start-tpm-client.sh
```

## Password Authorization

A plaintext password value may be used to authorize an action when use of an authValue is allowed. Unfortunately, this cannot be demonstrated here. tpm2-tools treats all password authorization as HMAC session-based authorization:
<!-- https://github.com/remuswu1019/tpm2-tools/commit/a82f766e9bc42df9cfbdb12712de071e4e539c9f -->
<!-- https://github.com/tpm2-software/tpm2-tools/pull/2719 -->

```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

# create a key safeguarded by the a password
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign" -p pass123
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# provide the password to access the key for signing use
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p pass123
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
```

## PCR

PCR bank allocation. In other words, enable/disable PCR banks. Cold/Warm reset the TPM after executing the following command to see the effects:
<!-- TPM2_PCR_Allocate() takes effect at _TPM_Init(), not TPM2_Startup(). -->
```
# enable only sha256 bank
$ tpm2_pcrallocate sha1:none+sha256:all+sha384:none
```

Read PCRs:
```
$ tpm2_pcrread
```

Compute and show the hash value of a file without extending to PCR:
```
$ echo "plaintext" > plain.txt
$ tpm2_pcrevent plain.txt
```

Extend a file to PCR:
```
$ echo "plaintext" > plain.txt
$ tpm2_pcrevent 8 plain.txt
```

Extend a hash value to PCR:
```
$ tpm2_pcrextend 9:sha256=beefcafebeefcafebeefcafebeefcafebeefcafebeefcafebeefcafebeefcafe
```

## Persistent Key

Make storage key persistent:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_evictcontrol -C o -c primary_sh.ctx 0x81000001
```

Make platform key persistent:
```
$ tpm2_createprimary -C p -g sha256 -G ecc -c primary_ph.ctx
$ tpm2_evictcontrol -C p -c primary_ph.ctx 0x81800001
```

List persistent handles:
```
$ tpm2_getcap handles-persistent
```

Access the persistent and non-persistent key:
```
$ tpm2_readpublic -c 0x81000001
$ tpm2_readpublic -c primary_sh.ctx
```

Evict persistent handle:
```
$ tpm2_evictcontrol -C o -c 0x81000001
$ tpm2_evictcontrol -C p -c 0x81800001
```

## PKCS #11

Please refer to [[7]](#7).

## Quote

to-do

## Read EK Certificate

This section only work on hardware TPM.

The issuing certificate authority (CA) and certificate revocation list (CRL) information of an EK certificate can be found in the EK certificate "X509v3 extensions" field.

Read RSA & ECC endorsement key certificates from NV:
```
# RSA
$ tpm2_nvread 0x1c00002 -o rsa_ek.crt.der
$ openssl x509 -inform der -in rsa_ek.crt.der -text

# ECC
$ tpm2_nvread 0x1c0000a -o ecc_ek.crt.der
$ openssl x509 -inform der -in ecc_ek.crt.der -text
```

Read RSA & ECC endorsement key certificates using tpm2-tools:
```
$ tpm2_getekcertificate -o rsa_ek.crt.der -o ecc_ek.crt.der
```

## Seal

Seal data to a TPM:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx

$ echo "some message" > message

# seal
$ tpm2_create -C primary_sh.ctx -i message -u message.seal.pub -r message.seal.priv
$ tpm2_load -C primary_sh.ctx -u message.seal.pub -r message.seal.priv -c message.seal.ctx

# unseal
$ tpm2_unseal -c message.seal.ctx -o message.unseal
$ diff message message.unseal
```

## Secure Key Transfer (Duplicate Key)

Examples showing here are in the following settings:
- Both sender and recipient resided on a same TPM. Alternatively, it is possible to have recipient on another TPM.
- Sender is a TPM. Alternatively, it is possible to have a non-TPM sender, check [[6]](#6) for detailed implementation guide.

### Without Credential Protection

\[Both\] Create duplication policy:
```
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx -L policy.ctx TPM2_CC_Duplicate
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Create a recipient's parent key:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -r recipient_parent.prv -u recipient_parent.pub -a "restricted|sensitivedataorigin|decrypt|userwithauth"
```

\[Sender\] Create an RSA key under the primary object:
```
$ tpm2_create -C primary_sh.ctx -g sha256 -G rsa -r rsakey.prv -u rsakey.pub -L policy.ctx -a "sensitivedataorigin|userwithauth|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -r rsakey.prv -u rsakey.pub -c rsakey.ctx
$ tpm2_readpublic -c rsakey.ctx -o rsakey.pub
```

\[Sender\] Create duplication blob:
```
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Duplicate
$ tpm2_loadexternal -C o -u recipient_parent.pub -c recipient_parent.ctx
$ tpm2_duplicate -C recipient_parent.ctx -c rsakey.ctx -G null -p session:session.ctx -r dup.priv -s dup.seed
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Import the blob (RSA key):
```
$ tpm2_load -C primary_sh.ctx -u recipient_parent.pub -r recipient_parent.prv -c recipient_parent.ctx
$ tpm2_import -C recipient_parent.ctx -u rsakey.pub -r rsakey_imported.prv -i dup.priv -s dup.seed
$ tpm2_load -C recipient_parent.ctx -u rsakey.pub -r rsakey_imported.prv -c rsakey_imported.ctx
```

### With Credential Protection

\[Both\] Create duplication policy:
```
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx -L policy.ctx TPM2_CC_Duplicate
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Create EK:
```
$ tpm2_createek -c 0x81010001 -G rsa -u ek.pub
```

\[Recipient\] Read recipient public component:
```
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_readpublic -c primary_sh.ctx -o recipient_parent.pub -n recipient_parent.name
```

\[Sender\] Create a sender's parent key:
```
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -r sender_parent.prv -u sender_parent.pub -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|restricted|decrypt"
$ tpm2_load -C primary_sh.ctx -u sender_parent.pub -r sender_parent.prv -c sender_parent.ctx
```

\[Sender\] Create an RSA key under the parent key:
```
$ tpm2_create -C sender_parent.ctx -g sha256 -G rsa -r rsakey.prv -u rsakey.pub -L policy.ctx -a "sensitivedataorigin|userwithauth|decrypt|sign"
$ tpm2_load -C sender_parent.ctx -r rsakey.prv -u rsakey.pub -c rsakey.ctx
$ tpm2_readpublic -c rsakey.ctx -o rsakey.pub
```

\[Sender\] Create an inner wrap key and protect it with EK credential. Usually, recipient should also provide EK certificate for verification purpose:
```
$ dd if=/dev/urandom of=innerwrapkey.clear bs=1 count=16
$ tpm2_makecredential -e ek.pub -s innerwrapkey.clear -n $(xxd -ps -c 100 recipient_parent.name) -o innerwrapkey.cipher
```

\[Sender\] Create duplication blob:
```
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Duplicate
$ tpm2_loadexternal -C o -u recipient_parent.pub -c recipient_parent.ctx
$ tpm2_duplicate -C recipient_parent.ctx -c rsakey.ctx -G aes -i innerwrapkey.clear -p session:session.ctx -r dup.priv -s dup.seed
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Recover the inner wrap key with EK credential:
```
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policysecret -S session.ctx -c e
$ tpm2_activatecredential -c primary_sh.ctx -C 0x81010001 -i innerwrapkey.cipher -o innerwrapkey.decipher -P session:session.ctx
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Import the blob (RSA key):
```
$ tpm2_import -C primary_sh.ctx -u rsakey.pub -r rsakey_imported.prv -k innerwrapkey.decipher -i dup.priv -s dup.seed
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey_imported.prv -c rsakey_imported.ctx
```

## Self Test

Self test command causes the TPM to perform a test of its capabilities. `tpm2_selftest -f` (full test) TPM will test all functions. `tpm2_selftest` (simple test) TPM will test functions that require testing.

Incremental self test causes the TPM to perform a test of the selected algorithms. If the command contains an algorithm that has already been tested, it will not be tested again. `tpm2_incrementalselftest` will return a list of algorithms left to be tested. Provide a list of algorithms to the command to start a test, e.g., `tpm2_incrementalselftest rsa ecc` will test the RSA & ECC algorithms and return a list of algorithms left to be tested.

`tpm2_gettestresult` returns manufacturer-specific information regarding the results of a self-test and an indication of the test status.

Once a TPM has received TPM2_SelfTest() and before completion of all tests, the TPM will return TPM_RC_TESTING for any command that uses a function that requires a test.

## Session-based Authorization

### HMAC

<!-- When the session is an HMAC session, the HMAC sessionKey is derived from the authValue -->

Commands below should have the same effect as password authorization due to tpm2-tools implementation. It treats all password authorization as HMAC session-based authorization:
```
# create a key safeguarded by the a password
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign" -p pass123
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# provide the password to access the key for signing use
$ tpm2_startauthsession --hmac-session -S session.ctx
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx+pass123
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx
```

### Policy

Also known as enhanced authorization.

Enhanced authorization is a TPM capability that allows entity-creators or administrators to require specific tests or actions to be performed before an action can be completed. The specific policy is encapsulated in a value called an authPolicy that is associated with an entity. When an HMAC session is used for authorization, the authValue of the entity is used to determine if the authorization is valid. When a policy session is used for authorization, the authPolicy of the entity is used.

#### tpm2_policyauthorize

Allows for mutable policies by tethering to a signing authority. In this approach, authority can add new policy but unable to revoke old policy:
<!-- This is an immediate assertion. This assertion evaluation checks to see if the current policyDigest is authorized by a signing key. So the order of tpm2_policyauthorize matters. Only authority signed policies should appear before tpm2_policyauthorize assertion, other policies should appear after tpm2_policyauthorize. -->

```
# create a signing authority
$ openssl genrsa -out authority_sk.pem 2048
$ openssl rsa -in authority_sk.pem -out authority_pk.pem -pubout
$ tpm2_loadexternal -C o -G rsa -u authority_pk.pem -c authority_key.ctx -n authority_key.name

# create an authorize policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyauthorize -S session.ctx -L authorize.policy -n authority_key.name
$ tpm2_flushcontext session.ctx

# create a policy to restrict a key to signing use only
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Sign -L sign.policy
$ tpm2_flushcontext session.ctx

# authority sign the policy
$ openssl dgst -sha256 -sign authority_sk.pem -out sign_policy.signature sign.policy

# create a key safeguarded by the authorize policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L authorize.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Sign
$ tpm2_verifysignature -c authority_key.ctx -g sha256 -m sign.policy -s sign_policy.signature -t sign_policy.ticket -f rsassa
$ tpm2_policyauthorize -S session.ctx -i sign.policy -n authority_key.name -t sign_policy.ticket
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

# create a new policy to restrict a key to decryption use only
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_RSA_Decrypt -L decrypt.policy
$ tpm2_flushcontext session.ctx

# authority sign the new policy
$ openssl dgst -sha256 -sign authority_sk.pem -out decrypt_policy.signature decrypt.policy

# encrypt some data
$ echo "some secret" > secret.clear
$ tpm2_rsaencrypt -c rsakey.ctx -o secret.cipher secret.clear

# satisfy the new policy to access the key for decryption use
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_RSA_Decrypt
$ tpm2_verifysignature -c authority_key.ctx -g sha256 -m decrypt.policy -s decrypt_policy.signature -t decrypt_policy.ticket -f rsassa
$ tpm2_policyauthorize -S session.ctx -i decrypt.policy -n authority_key.name -t decrypt_policy.ticket
$ tpm2_rsadecrypt -c rsakey.ctx -o secret.decipher secret.cipher -p session:session.ctx
$ diff secret.decipher secret.clear
$ tpm2_flushcontext session.ctx
```

#### tpm2_policyauthorizenv

Allows for mutable policies by referencing to a policy from an NV index. In other words, an object policy is stored in NV and it can be replaced any time, hence mutable policy:
<!-- This is an immediate assertion. This assertion evaluation checks to see if the current policyDigest is equivalent to the computed policy stored in NV. So the order of tpm2_policyauthorizenv matters. Only policies that associated with the policy value stored in NV should appear before tpm2_policyauthorizenv assertion, other policies should appear after tpm2_policyauthorizenv. -->

```
# create NV to store policy
$ tpm2_nvdefine -C o -p pass123 -a "authread|authwrite" -s 34 0x1000000

# create a policy to restrict a key to signing use only
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Sign -L sign.policy
$ tpm2_flushcontext session.ctx

# store the policy in NV
$ echo "000b" | xxd -p -r | cat - sign.policy > policy.bin
$ tpm2_nvwrite -P pass123 0x1000000 -i policy.bin

# create the authorize NV policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyauthorizenv -S session.ctx -C 0x1000000 -P pass123 -L authorizenv.policy 0x1000000
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the authorize NV policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L authorizenv.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy both policy to access the key for signing use
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Sign
$ tpm2_policyauthorizenv -S session.ctx -C 0x1000000 -P pass123 0x1000000
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

# create a new policy to restrict a key to decryption use only
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_RSA_Decrypt -L decrypt.policy
$ tpm2_flushcontext session.ctx

# replace the policy in NV
$ echo "000b" | xxd -p -r | cat - decrypt.policy > policy.bin
$ tpm2_nvwrite -P pass123 0x1000000 -i policy.bin

# encrypt some data
$ echo "some secret" > secret.clear
$ tpm2_rsaencrypt -c rsakey.ctx -o secret.cipher secret.clear

# satisfy the new policy to access the key for decryption use
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policycommandcode -S session.ctx TPM2_CC_RSA_Decrypt
$ tpm2_policyauthorizenv -S session.ctx -C 0x1000000 -P pass123 0x1000000
$ tpm2_rsadecrypt -c rsakey.ctx -o secret.decipher secret.cipher -p session:session.ctx
$ diff secret.decipher secret.clear
$ tpm2_flushcontext session.ctx
```

#### tpm2_policyauthvalue

Enables binding a policy to the authorization value of the authorized TPM object. Enables a policy that requires the object's authentication passphrase be provided. This is equivalent to authenticating using the object passphrase in HMAC, only this enforces it as a policy:

```
# create the policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyauthvalue -S session.ctx -L authvalue.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L authvalue.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign" -p pass123
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policyauthvalue -S session.ctx
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx+pass123
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx
```

#### tpm2_policycommandcode

Check policy command code `man tpm2_policycommandcode` for list of supported commands.

Restrict a key for signing use only:
```
# create the policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Sign -L sign.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L sign.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Sign
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx
```

#### tpm2_policycountertimer

Enables policy authorization by evaluating the comparison operation on the TPMS_CLOCK_INFO: reset count, restart count, time, clock, and clock safe flag.

One example is to restrict the usage of a key to only the first 2 minutes of TPM Clock:
```
# create the policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycountertimer -S session.ctx -L time.policy --ult clock=120000
$ tpm2_flushcontext session.ctx

# reset TPM clock
$ tpm2_clear -c p

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L time.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycountertimer -S session.ctx --ult clock=120000
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

# set the clock to future time
$ tpm2_setclock 120000

# attempt to access the key for signing use
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycountertimer -S session.ctx --ult clock=120000
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx <---- expected to fail
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx
```

#### tpm2_policycphash

Couples a policy with command parameters of the command. Used in conjunction with tpm2_policyauthorize/tpm2_policyauthorizenv.

<!--
The policy needs tpm2_policyauthorize/tpm2_policyauthorizenv otherwise it turns into a chicken and egg problem. We know from the beginning, a policy has to be created first then it is set to an object. Finally, the policy protected object can be used to perform certain actions (e.g., sign, decrypt, ...). However, to create tpm2_policycphash you will need to generate cpHash and the cpHash recipe requires an object name. And that is exactly the chicken and egg problem, you cant create tpm2_policycphash without creating an object first; on the other hand, you cant create an object without creating a policy first. To break the deadlock, create an object with tpm2_policyauthorize/tpm2_policyauthorizenv. Now tpm2_policycphash can be associated with the object at a later stage.
-->
```
# create a signing authority
$ openssl genrsa -out authority_sk.pem 2048
$ openssl rsa -in authority_sk.pem -out authority_pk.pem -pubout
$ tpm2_loadexternal -C o -G rsa -u authority_pk.pem -c authority_key.ctx -n authority_key.name

# create an authorize policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyauthorize -S session.ctx -L authorize.policy -n authority_key.name
$ tpm2_flushcontext session.ctx

# define a special purpose NV
# The authValue of this NV will be used to authorize pinCount reset
$ tpm2_nvdefine 0x01000001 -C o -a "authread|authwrite" -p pass123

# define an NV pinpass safeguarded by the authorize policy
$ tpm2_nvdefine 0x01000000 -C o -a "nt=pinpass|policywrite|authread|ownerwrite" -L authorize.policy

# initialize the NV
# set the TPMS_NV_PIN_COUNTER_PARAMETERS structure (pinCount=0|pinLimit=5)
$ echo -n -e '\x00\x00\x00\x00\x00\x00\x00\x05' > data
$ tpm2_nvwrite 0x01000000 -C o -i data

# obtain cphash (the command will calculate cphash without performing NV write)
# set the TPMS_NV_PIN_COUNTER_PARAMETERS structure (pinCount=0|pinLimit=5)
$ tpm2_nvwrite 0x01000000 -C 0x01000000 -i data --cphash cp.hash

# create cphash policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycphash -S session.ctx -L cphash.policy --cphash cp.hash             <----- restrict tpm2_nvwrite command parameters and handles
$ tpm2_policysecret -S session.ctx -L cphash+secret.policy -c 0x01000001 pass123 <----- use authvalue of another entity to authorize reset of pinCount
$ tpm2_flushcontext session.ctx

# authority sign the policy
$ openssl dgst -sha256 -sign authority_sk.pem -out cphash+secret_policy.signature cphash+secret.policy

# utilize NV authvalue to increase pinCount
$ tpm2_nvread 0x01000000 -C 0x01000000 | xxd -p    <----- notice pinCount increases by 1
$ tpm2_nvread 0x01000000 -C 0x01000000 | xxd -p
$ tpm2_nvread 0x01000000 -C 0x01000000 | xxd -p

# satisfy the policy and perform nvwrite to reset the pinCount
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycphash -S session.ctx --cphash cp.hash
$ tpm2_policysecret -S session.ctx -c 0x01000001 pass123
$ tpm2_verifysignature -c authority_key.ctx -g sha256 -m cphash+secret.policy -s cphash+secret_policy.signature -t cphash+secret_policy.ticket -f rsassa
$ tpm2_policyauthorize -S session.ctx -i cphash+secret.policy -n authority_key.name -t cphash+secret_policy.ticket
$ tpm2_nvwrite 0x01000000 -C 0x01000000 -i data -P session:session.ctx
$ tpm2_flushcontext session.ctx

# utilize NV authvalue to increase pinCount
$ tpm2_nvread 0x01000000 -C 0x01000000 | xxd -p    <----- notice pinCount back to 1

$ tpm2_nvundefine 0x01000000 -C o
$ tpm2_nvundefine 0x01000001 -C o
```

#### tpm2_policyduplicationselect

Restricts duplication to a specific new parent.

<!-- 
If duplication is allowed, authorization must always be provided by a policy session and the authPolicy equation of the object must contain a command that sets the policy command code to TPM_CC_Duplicate. tpm2_policyduplicationselect/tpm2_policycommandcode(TPM_CC_Duplicate) both will set policy command code to TPM_CC_Duplicate. There is no need to have both policies involve in a single operation.
-->

Not used in conjunction with tpm2_policyauthorize/tpm2_policyauthorizenv. Policy specifies only the new parent but not the duplication object:
```
# create a source (old) parent and destination (new) parent
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh_scr.ctx
$ tpm2_createprimary -C n -g sha256 -G ecc -c primary_sh_dest.ctx

# create a duplication policy
$ tpm2_readpublic -c primary_sh_dest.ctx -n primary_sh_dest.name
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyduplicationselect -S session.ctx -N primary_sh_dest.name -L duplicate.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_create -C primary_sh_scr.ctx -g sha256 -G ecc -u eckey.pub -r eckey.priv -L duplicate.policy -a "sensitivedataorigin|userwithauth|sign"
$ tpm2_load -C primary_sh_scr.ctx -u eckey.pub -r eckey.priv -n eckey.name -c eckey.ctx

# satisfy the policy and duplicate the key
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policyduplicationselect -S session.ctx -N primary_sh_dest.name -n eckey.name
$ tpm2_duplicate -C primary_sh_dest.ctx -c eckey.ctx -G null -p session:session.ctx -r eckey_dup.priv -s eckey_dup.seed
$ tpm2_flushcontext session.ctx

# import the key to the destination parent
$ tpm2_import -C primary_sh_dest.ctx -u eckey.pub -r eckey_imported.priv -i eckey_dup.priv -s eckey_dup.seed
$ tpm2_load -C primary_sh_dest.ctx -u eckey.pub -r eckey_imported.priv -c eckey_imported.ctx
```

Used in conjunction with tpm2_policyauthorize/tpm2_policyauthorizenv. Policy specifies the new parent and duplication object. This is to prevent other objects with PolicyAuthorize (with same authority) from being allowed to perform duplication:
```
# create a signing authority
$ openssl genrsa -out authority_sk.pem 2048
$ openssl rsa -in authority_sk.pem -out authority_pk.pem -pubout
$ tpm2_loadexternal -C o -G rsa -u authority_pk.pem -c authority_key.ctx -n authority_key.name

# create an authorize policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyauthorize -S session.ctx -L authorize.policy -n authority_key.name
$ tpm2_flushcontext session.ctx

# create a source (old) parent and destination (new) parent
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh_scr.ctx
$ tpm2_createprimary -C n -g sha256 -G ecc -c primary_sh_dest.ctx

# create a key safeguarded by the authorize policy
$ tpm2_create -C primary_sh_scr.ctx -G ecc -u eckey.pub -r eckey.priv -L authorize.policy -a "sensitivedataorigin|userwithauth|sign"
$ tpm2_load -C primary_sh_scr.ctx -u eckey.pub -r eckey.priv -n eckey.name -c eckey.ctx

# create a duplication policy
$ tpm2_readpublic -c primary_sh_dest.ctx -n primary_sh_dest.name
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyduplicationselect -S session.ctx -N primary_sh_dest.name -n eckey.name -L duplicate.policy
$ tpm2_flushcontext session.ctx

# authority sign the duplication policy
$ openssl dgst -sha256 -sign authority_sk.pem -out duplicate_policy.signature duplicate.policy

# satisfy the policy and duplicate the key
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policyduplicationselect -S session.ctx -N primary_sh_dest.name -n eckey.name
$ tpm2_verifysignature -c authority_key.ctx -g sha256 -m duplicate.policy -s duplicate_policy.signature -t duplicate_policy.ticket -f rsassa
$ tpm2_policyauthorize -S session.ctx -i duplicate.policy -n authority_key.name -t duplicate_policy.ticket
$ tpm2_duplicate -C primary_sh_dest.ctx -c eckey.ctx -G null -p session:session.ctx -r eckey_dup.priv -s eckey_dup.seed
$ tpm2_flushcontext session.ctx

# import the key to the destination parent
$ tpm2_import -C primary_sh_dest.ctx -u eckey.pub -r eckey_imported.priv -i eckey_dup.priv -s eckey_dup.seed
$ tpm2_load -C primary_sh_dest.ctx -u eckey.pub -r eckey_imported.priv -c eckey_imported.ctx
```

#### tpm2_policylocality

Restrict TPM object authorization to specific localities. Changing locality of TPM varies on different platforms. Linux driver doesn't expose a mechanism for user space applications to set locality for the moment ([[11]](#11)). The default locality used in Linux for user space applications is zero.

**Warning:** Apply the fix ([[12]](#12)) to pass the example using tpm2-tools version 5.2.

```
# create a locality policy
tpm2_startauthsession -S session.ctx
tpm2_policylocality -S session.ctx -L locality.policy zero
tpm2_flushcontext session.ctx

# create a key safeguarded by the locality policy
tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L locality.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

echo "plaintext" > plain.txt

# satisfy policy to access the key for signing use
tpm2_startauthsession -S session.ctx --policy-session
tpm2_policylocality -S session.ctx zero
tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
tpm2_flushcontext session.ctx
```

#### tpm2_policynamehash

Couples a policy with names of specific objects. Names of all object handles in a TPM command is checked against the one specified in the policy. Used in conjunction with tpm2_policyauthorize/tpm2_policyauthorizenv.

This command allows a policy to be bound to a specific set of TPM entities without being bound to the parameters of the command. This is most useful for commands such as TPM2_Duplicate() and for TPM2_PCR_Event() when the referenced PCR requires a policy.

Example, to authorize key duplication:
```
# create a signing authority
$ openssl genrsa -out authority_sk.pem 2048
$ openssl rsa -in authority_sk.pem -out authority_pk.pem -pubout
$ tpm2_loadexternal -C o -G rsa -u authority_pk.pem -c authority_key.ctx -n authority_key.name

# create an authorize + commandcode policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyauthorize -S session.ctx -n authority_key.name
$ tpm2_policycommandcode -S session.ctx -L authorize+cc.policy TPM2_CC_Duplicate
$ tpm2_flushcontext session.ctx

# create a source (old) parent and destination (new) parent
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh_scr.ctx
$ tpm2_createprimary -C n -g sha256 -G ecc -c primary_sh_dest.ctx

# create a key safeguarded by the authorize policy
$ tpm2_create -C primary_sh_scr.ctx -G ecc -u eckey.pub -r eckey.priv -L authorize+cc.policy -a "sensitivedataorigin|userwithauth|sign"
$ tpm2_load -C primary_sh_scr.ctx -u eckey.pub -r eckey.priv -n eckey.name -c eckey.ctx

# create a namehash policy
$ tpm2_readpublic -c primary_sh_dest.ctx -n primary_sh_dest.name
$ cat eckey.name primary_sh_dest.name | openssl dgst -sha256 -binary > name.hash
$ tpm2_startauthsession -S session.ctx
$ tpm2_policynamehash -S session.ctx -n name.hash -L namehash.policy
$ tpm2_flushcontext session.ctx

# authority sign the namehash policy
$ openssl dgst -sha256 -sign authority_sk.pem -out namehash_policy.signature namehash.policy

# satisfy the policy and duplicate the key
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policynamehash -S session.ctx -n name.hash
$ tpm2_verifysignature -c authority_key.ctx -g sha256 -m namehash.policy -s namehash_policy.signature -t namehash_policy.ticket -f rsassa
$ tpm2_policyauthorize -S session.ctx -i namehash.policy -n authority_key.name -t namehash_policy.ticket
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Duplicate
$ tpm2_duplicate -C primary_sh_dest.ctx -c eckey.ctx -G null -p session:session.ctx -r eckey_dup.priv -s eckey_dup.seed
$ tpm2_flushcontext session.ctx

# import the key to the destination parent
$ tpm2_import -C primary_sh_dest.ctx -u eckey.pub -r eckey_imported.priv -i eckey_dup.priv -s eckey_dup.seed
$ tpm2_load -C primary_sh_dest.ctx -u eckey.pub -r eckey_imported.priv -c eckey_imported.ctx
```

<!-- Need better examples... -->

<!--
TPM_CC_PCR_SetAuthPolicy not supported so skip this.

Example, pcrevent:
```
```
-->

#### tpm2_policynv

Evaluates policy authorization by comparing a specified value against the contents in the specified NV Index. The comparison operator can be specified as follows:
- "eq" if operandA = operandB
- "neq" if operandA != operandB
- "sgt" if signed operandA > signed operandB
- "ugt" if unsigned operandA > unsigned operandB
- "slt" if signed operandA < signed operandB
- "ult" if unsigned operandA < unsigned operandB
- "sge" if signed operandA >= signed operandB
- "uge" if unsigned operandA >= unsigned operandB
- "sle" if signed operandA <= unsigned operandB
- "ule" if unsigned operandA <= unsigned operandB
- "bs" if all bits set in operandA are set in operandB
- "bc" if all bits set in operandA are clear in operandB

<!-- It is an immediate assertion. The name of NV index is taken into the policy calculation, so the NV has to be initialized before trial policy session. -->

Example using "eq":
```
# define a special purpose NV
# The value of this NV will be used for authorization
$ tpm2_nvdefine 0x01000000 -C o -a "authread|authwrite" -s 1 -p pass123

# initialize the NV before creating the policy
$ echo -n -e '\x00' > init.bin
$ tpm2_nvwrite 0x01000000 -C 0x01000000 -P pass123 -i init.bin

# create policynv. The policy checks if the NV value is equivalent to expected.bin
$ echo -n -e '\x55' > expected.bin
$ tpm2_startauthsession -S session.ctx
$ tpm2_policynv -S session.ctx 0x01000000 eq -i expected.bin -P pass123 -L nv.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L nv.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

# write the expected data into NV
$ echo -n -e '\x55' > data.bin
$ tpm2_nvwrite 0x01000000 -C 0x01000000 -P pass123 -i data.bin

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policynv -S session.ctx 0x01000000 eq -i expected.bin -P pass123
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

$ tpm2_nvundefine 0x01000000 -C o
```

#### tpm2_policynvwritten

Restrict TPM object authorization to the written state (TPMA_NV_WRITTEN attribute) of an NV index.

Example, create a one time programmable NV:
```
# create the policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_NV_Write
$ tpm2_policynvwritten -S session.ctx -L cc+nvwritten.policy c
$ tpm2_flushcontext session.ctx

# define an NV safeguarded by the policy
$ tpm2_nvdefine -C o 0x01000000 -s 1 -a "authread|policywrite" -L cc+nvwritten.policy

# satisfy the policy and write the NV
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policycommandcode -S session.ctx TPM2_CC_NV_Write
$ tpm2_policynvwritten -S session.ctx c
$ echo 0xAA | xxd -r -p | tpm2_nvwrite 0x01000000 -i - -P session:session.ctx
$ tpm2_flushcontext session.ctx

$ tpm2_nvundefine 0x01000000 -C o
```

#### tpm2_policyor

Logically OR's two policies together.

```
# define a special purpose NV
# The authValue of this NV will be used on another entity
$ tpm2_nvdefine 0x01000000 -C o -a "authread|authwrite" -s 1 -p admin123

# create a secret policy to use authValue of another entity
$ tpm2_startauthsession -S session.ctx
$ tpm2_policysecret -S session.ctx -c 0x01000000 -L secret.policy admin123
$ tpm2_flushcontext session.ctx

# create an authvalue policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyauthvalue -S session.ctx -L authvalue.policy
$ tpm2_flushcontext session.ctx

# compound the two policies in an OR fashion
$ tpm2_startauthsession -S session.ctx
$ tpm2_policyor -S session.ctx -L secret+or+authvalue.policy sha256:secret.policy,authvalue.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -p user123 -L secret+or+authvalue.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

# satisfy just the secret policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policysecret -S session.ctx -c 0x01000000 admin123
$ tpm2_policyor -S session.ctx sha256:secret.policy,authvalue.policy
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

# satisfy just the authvalue policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policyauthvalue -S session.ctx
$ tpm2_policyor -S session.ctx sha256:secret.policy,authvalue.policy
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx+user123
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

$ tpm2_nvundefine 0x01000000 -C o
```

#### tpm2_policypassword

Enables binding a policy to the authorization value of the authorized TPM object. Enables a policy that requires the object's authentication passphrase be provided. This is equivalent to authenticating using the object passphrase in plaintext, only this enforces it as a policy.

```
# create the policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policypassword -S session.ctx -L authvalue.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L authvalue.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign" -p pass123
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policypassword -S session.ctx
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx+pass123
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx
```

#### tpm2_policypcr

Create a policy that includes specific PCR values.

```
# check if sha256 bank of pcr is enabled
# if it is not, enable it using tpm2_pcrallocate
$ tpm2_pcrread

# create the pcr policy
$ tpm2_pcrread "sha256:0,1,2,3" -o pcr.bin
$ tpm2_startauthsession -S session.ctx
$ tpm2_policypcr -S session.ctx -l "sha256:0,1,2,3" -f pcr.bin -L pcr.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -L pcr.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

$ echo "plaintext" > plain.txt

# satisfy the policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policypcr -S session.ctx -l "sha256:0,1,2,3" -f pcr.bin
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx+pass123
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx

# change the value of pcr
$ tpm2_pcrextend 1:sha256=beefcafebeefcafebeefcafebeefcafebeefcafebeefcafebeefcafebeefcafe

# attempt to satisfy the policy, expected to fail
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policypcr -S session.ctx -l "sha256:0,1,2,3" -f pcr.bin
$ tpm2_flushcontext session.ctx
```

#### tpm2_policyrestart

This is not a policy. This command allows a policy authorization session to be returned to its initial state.

You may restart the existing session:
```
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policy...
$ tpm2_...
$ tpm2_policyrestart -S session.ctx
$ tpm2_policy...
$ tpm2_...
$ tpm2_policyrestart -S session.ctx
$ tpm2_policy...
$ tpm2_...
$ tpm2_flushcontext session.ctx
```

#### tpm2_policysecret

Couples the authorization of an object to that of an existing object.

<!--
contain a special feature where you can set/get time when authorization will expire, this is unique to policySecret only, but not implemented in tpm2-tools...
-->

```
# define a special purpose NV
# The authValue of this NV will be used on another entity
$ tpm2_nvdefine 0x01000000 -C o -a "authread|authwrite" -s 1 -p admin123

# create a secret policy to use authValue of another entity
$ tpm2_startauthsession -S session.ctx
$ tpm2_policysecret -S session.ctx -c 0x01000000 -L secret.policy admin123
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -p user123 -L secret.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

# satisfy the policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policysecret -S session.ctx -c 0x01000000 admin123
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx
```

#### tpm2_policysigned

Enables policy authorization by verifying signature of optional TPM2 parameters. The authorizing entity will sign a digest of the authorization qualifiers:
- nonceTPM: the nonceTPM parameter from the TPM2_StartAuthSession() response. If the authorization is not limited to this session, the size of this value is zero.
- expiration: time limit on authorization set by authorizing object. This 32-bit value is set to zero if the expiration time is not being set.
- cpHashA: digest of the command parameters for the command being approved using the hash algorithm of the policy session. Set to an Empty Digest if the authorization is not limited to a specific command.
- policyRef: an opaque value determined by the authorizing entity. Set to the Empty Buffer if no value is present.

Example with all qualifiers set to zero/empty buffer:
```
# create a signing authority
$ openssl genrsa -out authority_sk.pem 2048
$ openssl rsa -in authority_sk.pem -out authority_pk.pem -pubout
$ tpm2_loadexternal -C o -G rsa -u authority_pk.pem -c authority_key.ctx -n authority_key.name

# authority sign the digest of the authorization qualifiers
$ echo "00 00 00 00" | xxd -r -p > qualifiers.bin
$ openssl dgst -sha256 -sign authority_sk.pem -out qualifiers.signature qualifiers.bin

# create the policy
$ tpm2_startauthsession -S session.ctx
$ tpm2_policysigned -S session.ctx -g sha256 -s qualifiers.signature -f rsassa -c authority_key.ctx -L signed.policy
$ tpm2_flushcontext session.ctx

# create a key safeguarded by the policy
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -G rsa -u rsakey.pub -r rsakey.priv -p user123 -L signed.policy -a "fixedtpm|fixedparent|sensitivedataorigin|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey.priv -n rsakey.name -c rsakey.ctx

# satisfy the policy and use the key for signing
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policysigned -S session.ctx -g sha256 -s qualifiers.signature -f rsassa -c authority_key.ctx
$ tpm2_sign -c rsakey.ctx -o signature plain.txt -p session:session.ctx
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m plain.txt -s signature
$ tpm2_flushcontext session.ctx
```

<!-- Need better examples... -->

#### tpm2_policytemplate

Couples a policy with public template of an object.

```
# get the primary key template hash
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx --template-data primary_sh.template
$ openssl dgst -sha256 -binary -out primary_sh.template.hash primary_sh.template

# create the policy
tpm2_startauthsession -S session.ctx
tpm2_policytemplate -S session.ctx --template-hash primary_sh.template.hash -L template.policy
tpm2_flushcontext session.ctx

# set storage hierarchy policy
$ tpm2_setprimarypolicy -C o -g sha256 -L template.policy

# set storage hierarchy authValue
$ tpm2_changeauth -c o ownerpswd

# satisfy the policy and create primary key
$ tpm2_startauthsession -S session.ctx --policy-session
$ tpm2_policytemplate -S session.ctx --template-hash primary_sh.template.hash
$ tpm2_createprimary -C o -g sha256 -G ecc -c primary_sh.ctx -P session:session.ctx
$ tpm2_flushcontext session.ctx
```

#### tpm2_policyticket

Enables policy authorization by verifying a ticket that represents a validated authorization that had an expiration time associated with it.

## Set Hierarchy Auth Value

Set storage hierarchy auth:
```
$ tpm2_changeauth -c o ownerpswd
```

Set endorsement hierarchy auth:
```
$ tpm2_changeauth -c e endorsementpswd
```

Set platform hierarchy auth:
```
$ tpm2_changeauth -c p platformpswd
```

Set lockout auth:
```
$ tpm2_changeauth -c l lockoutpswd
```

Platform auth value is not persistent, after a TPM reset, it will be set to empty auth.

Check auth set information:
```
$ tpm2_getcap properties-variable
```

## Set Hierarchy Policy

Sets the authorization policy for the lockout, the platform hierarchy, the storage hierarchy, and the endorsement hierarchy using the command `tpm2_setprimarypolicy`.

## Signing & Verification

Using RSA key:
```
$ echo "some message" > message
$ tpm2_sign -c rsakey.ctx -g sha256 -o signature message
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m message -s signature

# or use OpenSSL to verify signature

$ echo "some message" > message
$ tpm2_sign -c rsakey.ctx -g sha256 -f plain -o signature message
$ tpm2_readpublic -c rsakey.ctx -o public.pem -f pem
$ openssl dgst -sha256 -verify public.pem -keyform pem -signature signature message
```

Using ECC key:
```
$ echo "some message" > message
$ tpm2_sign -c eckey.ctx -g sha256 -o signature message
$ tpm2_verifysignature -c eckey.ctx -g sha256 -m message -s signature

# or use OpenSSL to verify signature

$ echo "some message" > message
$ tpm2_sign -c eckey.ctx -g sha256 -f plain -o signature message
$ tpm2_readpublic -c eckey.ctx -o public.pem -f pem
$ openssl dgst -sha256 -verify public.pem -keyform pem -signature signature message
```

Keyed-hash (HMAC):
```
$ echo "some message" > message
$ tpm2_hmac -c hmackey.ctx --hex message
```

## Startup

Type of startup and shutdown operations:

- `tpm2_startup -c` to perform Startup(TPM_SU_CLEAR)
- `tpm2_startup` to perform Startup(TPM_SU_STATE), this requires a preceding Shutdown(TPM_SU_STATE)
- `tpm2_shutdown -c` to perform Shutdown(TPM_SU_CLEAR)
- `tpm2_shutdown` to perform Shutdown(TPM_SU_STATE)

3 methods of preparing a TPM for operation:

1. TPM Reset: Startup(TPM_SU_CLEAR) that follows a Shutdown(TPM_SU_CLEAR), or Startup(TPM_SU_CLEAR) for which there was no preceding Shutdown() (a disorderly shutdown). A TPM reset is roughly analogous to a **reboot** of a platform.
    ```
    $ tpm2_shutdown -c
    < cold/warm reset >
    $ tpm2_startup -c
    ```
2. TPM Restart: Startup(TPM_SU_CLEAR) that follows a Shutdown(TPM_SU_STATE). This indicates a system that is restoring the OS from non-volatile storage, sometimes called **"hibernation"**. For a TPM restart, the TPM restores values saved by the preceding Shutdown(TPM_SU_STATE) except that all the PCR are set to their default initial state.
    ```
    $ tpm2_shutdown
    < cold/warm reset >
    $ tpm2_startup -c
    ```
3. TPM Resume: Startup(TPM_SU_STATE) that follows a Shutdown(TPM_SU_STATE). This indicates a system that is restarting the OS from RAM memory, sometimes called **"sleep"**. TPM Resume restores all of the state that was saved by Shutdown(STATE), including those PCR that are designated as being preserved by Startup(STATE). PCR not designated as being preserved, are reset to their default initial state.
    ```
    $ tpm2_shutdown
    < cold/warm reset >
    $ tpm2_startup
    ```

*Remarks:*
- *Cold reset means power on reset*
- *Warm reset means using the TPM RST signal (reset pin) to trigger a reset without losing power*

## TPM Clear

Perform TPM clear using platform or lockout hierarchy:
```
$ tpm2_clear -c p
$ tpm2_clear -c l
```

TPM clear highlights:
- Flush any transient or persistent objects associated with the storage or endorsement hierarchies
- Release any NV index locations that do not have their `platformcreate` attribute SET
- Set shEnable, ehEnable, phEnable to TRUE
- Set ownerAuth, endorsementAuth, and lockoutAuth to an empty auth
- Set ownerPolicy, endorsementPolicy, and lockoutPolicy to an empty policy
- Change the storage primary seed (SPS) to a new value from the TPM's random number generator

To change the platform primary seed (PPS) to a new value from the TPM's random number generator:
```
$ tpm2_changepps
```

To change the endorsement primary seed (EPS) to a new value from the TPM's random number generator. **This action will change the EK thus the EK certificate will also become unusable.**:
```
$ tpm2_changeeps
```

# References

<a id="1">[1] https://www.infineon.com/cms/en/product/security-smart-card-solutions/optiga-embedded-security-solutions/optiga-tpm/</a><br>
<a id="2">[2] https://github.com/microsoft/ms-tpm-20-ref</a><br>
<a id="3">[3] https://github.com/tpm2-software/tpm2-tss</a><br>
<a id="4">[4] https://github.com/tpm2-software/tpm2-tools</a><br>
<a id="5">[5] https://github.com/tpm2-software/tpm2-tss-engine</a><br>
<a id="6">[6] https://github.com/Infineon/ek-based-onboarding-optiga-tpm</a><br>
<a id="7">[7] https://github.com/Infineon/pkcs11-optiga-tpm</a><br>
<a id="8">[8] https://github.com/wxleong/tpm2-rpi4</a><br>
<a id="9">[9] https://trustedcomputinggroup.org/resource/tpm-library-specification/</a><br>
<a id="10">[10] https://www.infineon.com/cms/en/product/evaluation-boards/iridium9670-tpm2.0-linux/</a><br>
<a id="11">[11] https://github.com/tpm2-software/tpm2-tss/blob/master/src/tss2-tcti/tcti-device.c#L371</a><br>
<a id="12">[12] https://github.com/tpm2-software/tpm2-tools/commit/7b6600d3214dd45531bdb53d5f2510404c31fd6b#diff-b7ca48acb8f12449d165509c68d04600fac53b56bfc4c43462908815b9602def</a><br>

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# To-do

- NV platform/storage, ...
- Policies