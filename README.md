# Introduction

OPTIGA™ TPM 2.0 command reference and code examples.

# Table of Contents

- **[Prerequisites](#prerequisites)**
- **[Setup](#setup)**
- **[Using Hardware TPM](#using-hardware-tpm)**
- **[Behaviour of Microsoft TPM2.0 Simulator](#behaviour-of-microsoft-tpm20-simulator)**
- **[Examples](#examples)**
    - **[Startup](#startup)**
	- **[Display TPM Capabilities](#display-tpm-capabilities)**
    - **[Self Test](#self-test)**
    - **[Create Keys](#create-keys)**
    - **[Persistent Key](#persistent-key)**
    - **[Hierarchy Control](#hierarchy-control)**
    - **[Set Hierarchy Auth Value](#set-hierarchy-auth-value)**
    - **[Set Hierarchy Policy](#set-hierarchy-policy)**
    - **[TPM Clear](#tpm-clear)**
    - **[Dictionary Attack Protection](#dictionary-attack-protection)**
    - **[Get Random](#get-random)**
    - **[Encryption & Decryption](#encryption--decryption)**
    - **[Signing & Verification](#signing--verification)**
    - **[Hashing](#hashing)**
    - **[Certify](#certify)**
    - **[NV Storage](#nv-storage)**
	- **[Read EK Certificate](#read-ek-certificate)**
    - **[Audit](#audit)**
    - **[Policy](#policy)**
    - **[Import Externally Created key](#import-externally-created-key)**
    - **[EK Credential](#ek-credential)**
    - **[Secure Key Transfer](#secure-key-transfer)**
        - **[Without Credential Protection](#without-credential-protection)**
        - **[With Credential Protection](#with-credential-protection)**
    - **[Encrypted Session](#encrypted-session)**
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
    - **[PKCS #11](#pkcs-11)**
- **[References](#references)**
- **[License](#license)**

# Prerequisites

- Tested on: 
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

If you have hardware TPM enabled on your Linux platform (one example is using Raspberry Pi 4 [[8]](#8)), set the TCTI to device node `tpm0` or `tpmrm0`:
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

## Startup

Type of startup and shutdown operations:

- `tpm2_startup -c` to perform Startup(TPM_SU_CLEAR)
- `tpm2_startup` to perform Startup(TPM_SU_STATE), this requires a preceding Shutdown(TPM_SU_STATE)
- `tpm2_shutdown -c` to perform Shutdown(TPM_SU_CLEAR)
- `tpm2_shutdown` to perform Shutdown(TPM_SU_STATE)

3 methods of preparing a TPM for operation:

1. TPM reset: Startup(TPM_SU_CLEAR) that follows a Shutdown(TPM_SU_CLEAR), or Startup(TPM_SU_CLEAR) for which there was no preceding Shutdown() (a disorderly shutdown). A TPM reset is roughly analogous to a **reboot** of a platform.
2. TPM restart: Startup(TPM_SU_CLEAR) that follows a Shutdown(TPM_SU_STATE). This indicates a system that is restoring the OS from non-volatile storage, sometimes called **"hibernation"**. For a TPM restart, the TPM restores values saved by the preceding Shutdown(TPM_SU_STATE) except that all the PCR are set to their default initial state.
3. TPM resume: Startup(TPM_SU_STATE) that follows a Shutdown(TPM_SU_STATE). This indicates a system that is restarting the OS from RAM memory, sometimes called **"sleep"**. TPM Resume restores all of the state that was saved by Shutdown(STATE), including those PCR that are designated as being preserved by Startup(STATE). PCR not designated as being preserved, are reset to their default initial state.

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

Find TPM2.0 library specification revision by:
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

## Self Test

Self test command causes the TPM to perform a test of its capabilities. `tpm2_selftest -f` (full test) TPM will test all functions. `tpm2_selftest` (simple test) TPM will test functions that require testing.

Incremental self test causes the TPM to perform a test of the selected algorithms. If the command contains an algorithm that has already been tested, it will not be tested again. `tpm2_incrementalselftest` will return a list of algorithms left to be tested. Provide a list of algorithms to the command to start a test, e.g., `tpm2_incrementalselftest rsa ecc` will test the RSA & ECC algorithms and return a list of algorithms left to be tested.

`tpm2_gettestresult` returns manufacturer-specific information regarding the results of a self-test and an indication of the test status.

Once a TPM has received TPM2_SelfTest() and before completion of all tests, the TPM will return TPM_RC_TESTING for any command that uses a function that requires a test.

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

## Persistent Key

Make storage key persistent:
```
$ tpm2_evictcontrol -C o -c primary_sh.ctx 0x81000001
```

Make platform key persistent:
```
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

## Get Random

Get 16 bytes of random:
```
$ tpm2_getrandom --hex 16
```

## Encryption & Decryption

Using RSA key:
```
$ echo "some secret" > secret.clear
$ tpm2_rsaencrypt -c rsakey.ctx -o secret.cipher secret.clear
$ tpm2_rsadecrypt -c rsakey.ctx -o secret.decipher secret.cipher
$ diff secret.decipher secret.clear
```

## Signing & Verification

Using RSA key:
```
$ echo "some message" > message
$ tpm2_sign -c rsakey.ctx -g sha256 -o signature message
$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m message -s signature
```

Keyed-hash (HMAC):
```
$ echo "some message" > message
$ tpm2_hmac -c hmackey.ctx --hex message
```

## Hashing

```
$ echo "some message" > message
$ tpm2_hash -g sha256 --hex message
```

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
$ tpm2_certify -C signing.key.ctx -c primary_sh.ctx -p session:session.ctx -g sha256 -o attest.out -s sig.out
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s sig.out
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

When an object is created, the TPM creates a creation data that describes the environment in which the object was created. The TPM also produces a ticket that will allow the TPM to validate that the creation data was generated by the TPM. In other words, this allows the TPM to certify that it created the Object (TPM2_CertifyCreation()). This is most useful when fixedTPM is CLEAR in the created object.

<!-- tpm2_certifycreation not accepting session.ctx correctly? bug in the tools? getting error: "0x12F: authValue or authPolicy is not available for selected entity"
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
$ tpm2_certifycreation -C signing.key.ctx -c primary_sh.ctx -S session.ctx -d creation.data.hash -t creation.ticket -g sha256 -o sig.out --attestation attest.out
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s sig.out
```-->
```
$ tpm2_createprimary -C o -g sha256 -G ecc --creation-data creation.data -d creation.data.hash -t creation.ticket -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv
$ tpm2_load -C primary_sh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_certifycreation -C signing.key.ctx -c primary_sh.ctx -d creation.data.hash -t creation.ticket -g sha256 -o sig.out --attestation attest.out

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s sig.out
```

<!-- This is not implemented
<ins><b>tpm2_nvcertify</b></ins>

Provides attestation of the contents of an NV index:

```
# Create a policy to restrict the usage of a signing key to only command TPM2_CC_CertifyCreation
$ tpm2_startauthsession -S session.ctx
$ tpm2_policycommandcode -S session.ctx -L policy.ctx TPM2_CC_NV_Certify
$ tpm2_flushcontext session.ctx

$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -C o -s 32 -a "ownerwrite|ownerread"
$ tpm2_nvwrite 0x01000000 -C o -i data

$ tpm2_createprimary -C o -g sha256 -G ecc --creation-data creation.data -d creation.data.hash -t creation.ticket -c primary_sh.ctx
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv -L policy.ctx -a "fixedtpm|fixedparent|sensitivedataorigin|adminwithpolicy|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_nvcertify -C signing.key.ctx -g sha256 -o sig.out --attestation attest.out --size 32 0x01000000
$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s sig.out
```
-->

## NV Storage

NV define, write, and read:
```
$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -C o -s 32 -a "ownerwrite|ownerread"
$ tpm2_nvwrite 0x01000000 -C o -i data
$ tpm2_nvread 0x01000000 -C o -o out
$ diff data out
```

Read NV index:
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

## Audit

<ins><b>tpm2_getsessionauditdigest</b></ins>

Retrieve the session audit digest attestation data from the TPM. The attestation data includes the session audit digest and a signature over the session audit digest:

```
$ tpm2_createprimary -C e -g sha256 -G ecc -c primary_eh.ctx
$ tpm2_create -C primary_eh.ctx -g sha256 -G ecc -u signing.key.pub -r signing.key.priv
$ tpm2_load -C primary_eh.ctx -u signing.key.pub -r signing.key.priv -c signing.key.ctx

$ tpm2_startauthsession -S session.ctx --audit-session
$ tpm2_getrandom 1 --hex -S session.ctx
$ tpm2_getsessionauditdigest -c signing.key.ctx -g sha256 -m attest.out -s sig.out -S session.ctx
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c signing.key.ctx -g sha256 -m attest.out -s sig.out
```

<!-- command not supported
<ins><b>tpm2_setcommandauditstatus</b></ins>

Add or remove TPM2 commands to the audited commands list.
-->

<!-- command not supported
<ins><b>tpm2_getcommandauditdigest</b></ins>

Retrieve the command audit attestation data from the TPM. The attestation data includes the audit digest of the commands in the setlist setup using the command `tpm2_setcommandauditstatus`. Also the attestation data includes the digest of the list of commands setup for audit. The audit digest algorith is setup in the `tpm2_setcommandauditstatus`.
       
tpm2_getcommandauditdigest -c signing.key.ctx -g sha256 -m attest.out -s sig.out
-->

## Policy

### tpm2_policyauthorize

Allows for mutable policies by tethering to a signing authority.

### tpm2_policyauthorizenv

Allows for mutable policies by referencing to a policy from an NV index. In other words, an object policy is stored in NV and it can be changed any time, hence mutable policy.

### tpm2_policyauthvalue

Enables binding a policy to the authorization value of the authorized TPM object. Enables a policy that requires the object's authentication passphrase be provided. This is equivalent to authenticating using the object passphrase in plaintext !!or HMAC!!, only this enforces it as a policy.

### tpm2_policycommandcode

Check policy command code `man tpm2_policycommandcode` for list of supported commands.

### tpm2_policycountertimer

Enables policy authorization by evaluating the comparison operation on the TPMS_CLOCK_INFO: clock, reset count, restart count, and TPM clock safe flag.

### tpm2_policycphash

Couples a policy with command parameters of the command.

### tpm2_policyduplicationselect

Restricts duplication to a specific new parent.

### tpm2_policylocality

Restrict TPM object authorization to specific localities.

### tpm2_policynamehash

Couples a policy with names of specific objects.

### tpm2_policynv

Evaluates policy authorization by comparing a specified value against the contents in the specified NV Index.

### tpm2_policynvwritten

Restrict TPM object authorization to the written state (TPMA_NV_WRITTEN attribute) of an NV index.

### tpm2_policyor

Logically OR's two policies together.

### tpm2_policypassword

Enables binding a policy to the authorization value of the authorized TPM object. Enables a policy that requires the object's authentication passphrase be provided. This is equivalent to authenticating using the object passphrase in plaintext, only this enforces it as a policy.

### tpm2_policypcr

Create a policy that includes specific PCR values.

### tpm2_policyrestart

This is not a policy. This command is used for restarting an existing session with the TPM by clearing the policy digest to its initial state.

### tpm2_policysecret

Couples the authorization of an object to that of an existing object.

### tpm2_policysigned

Enables policy authorization by verifying signature of optional TPM2 parameters (nonceTPM || expiration || cpHashA || policyRef)). The signature is generated by a signing authority.

### tpm2_policytemplate

Couples a policy with public template of an object.

### tpm2_policyticket

Enables policy authorization by verifying a ticket that represents a validated authorization that had an expiration time associated with it.

## Import Externally Created key

RSA key:
```
$ openssl genrsa -out rsa_private.pem 2048
$ tpm2_import -C primary_sh.ctx -G rsa -i rsa_private.pem -u rsakey_imported.pub -r rsakey_imported.priv
$ tpm2_load -C primary_sh.ctx -u rsakey_imported.pub -r rsakey_imported.priv -c rsakey_imported.ctx
```

EC key:
```
$ openssl ecparam -name prime256v1 -genkey -noout -out ecc_private.pem
$ tpm2_import -C primary_sh.ctx -G ecc -i ecc_private.pem -u eckey_imported.pub -r eckey_imported.priv
$ tpm2_load -C primary_sh.ctx -u eckey_imported.pub -r eckey_imported.priv -c eckey_imported.ctx
```

HMAC key:
```
$ dd if=/dev/urandom of=raw.key bs=1 count=32
$ tpm2_import -C primary_sh.ctx -G hmac -i raw.key -u hmackey_imported.pub -r hmackey_imported.priv
$ tpm2_load -C primary_sh.ctx -u hmackey_imported.pub -r hmackey_imported.priv -c hmackey_imported.ctx
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
$ tpm2_activatecredential -c 0x81010002 -C 0x81010001 -i data.cipher -o data.decipher -P "session:session.ctx"
$ tpm2_flushcontext session.ctx
$ diff data.decipher data.clear
```

## Secure Key Transfer

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
$ tpm2_create -C primary_sh.ctx -g sha256 -G ecc -r recipient_parent.prv -u recipient_parent.pub -a "restricted|sensitivedataorigin|decrypt|userwithauth"
```

\[Sender\] Create an RSA key under the primary object:
```
$ tpm2_create -C primary_sh.ctx -g sha256 -G rsa -r rsakey.prv -u rsakey.pub  -L policy.ctx -a "sensitivedataorigin|userwithauth|decrypt|sign"
$ tpm2_load -C primary_sh.ctx -r rsakey.prv -u rsakey.pub -c rsakey.ctx
$ tpm2_readpublic -c rsakey.ctx -o rsakey.pub
```

\[Sender\] Create duplication blob:
```
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policycommandcode -S session.ctx TPM2_CC_Duplicate
$ tpm2_loadexternal -C o -u recipient_parent.pub -c recipient_parent.ctx
$ tpm2_duplicate -C recipient_parent.ctx -c rsakey.ctx -G null -p "session:session.ctx" -r dup.priv -s dup.seed
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Import the blob (RSA key):
```
$ tpm2_load -C primary_sh.ctx -u recipient_parent.pub -r recipient_parent.prv -c recipient_parent.ctx
$ tpm2_import -C recipient_parent.ctx -u rsakey.pub -r rsakey_imported.prv -i dup.priv -s dup.seed -L policy.ctx
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
$ tpm2_duplicate -C recipient_parent.ctx -c rsakey.ctx -G aes -i innerwrapkey.clear -p "session:session.ctx" -r dup.priv -s dup.seed
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Recover the inner wrap key with EK credential:
```
$ tpm2_startauthsession --policy-session -S session.ctx
$ tpm2_policysecret -S session.ctx -c e
$ tpm2_activatecredential -c primary_sh.ctx -C 0x81010001 -i innerwrapkey.cipher -o innerwrapkey.decipher -P "session:session.ctx"
$ tpm2_flushcontext session.ctx
```

\[Recipient\] Import the blob (RSA key):
```
$ tpm2_import -C primary_sh.ctx -u rsakey.pub -r rsakey_imported.prv -k innerwrapkey.decipher -i dup.priv -s dup.seed -L policy.ctx
$ tpm2_load -C primary_sh.ctx -u rsakey.pub -r rsakey_imported.prv -c rsakey_imported.ctx
```

## Encrypted Session

Using a HMAC session to enable encryption of selected parameters.

Get random:
```
$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_getrandom -S session.ctx --hex 16
$ tpm2_flushcontext session.ctx
```

Decryption:
```
$ echo "some secret" > secret.clear
$ tpm2_rsaencrypt -c rsakey.ctx -o secret.cipher secret.clear

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_rsadecrypt -p session:session.ctx -c rsakey.ctx -o secret.decipher secret.cipher
$ tpm2_flushcontext session.ctx
```

Sign:
```
$ echo "some message" > message

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_sign -p session:session.ctx -c rsakey.ctx -g sha256 -o signature message
$ tpm2_flushcontext session.ctx

$ tpm2_verifysignature -c rsakey.ctx -g sha256 -m message -s signature
```

HMAC:
```
$ echo "some message" > message

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_hmac -p session:session.ctx -c hmackey.ctx --hex message
$ tpm2_flushcontext session.ctx
```

NV operations:
```
$ dd bs=1 count=32 </dev/urandom >data
$ tpm2_nvdefine 0x01000000 -C o -s 32 -a "ownerwrite|ownerread"

$ tpm2_startauthsession --hmac-session -c primary_sh.ctx -S session.ctx
$ tpm2_nvwrite 0x01000000 -P session:session.ctx -C o -i data
$ tpm2_nvread 0x01000000 -P session:session.ctx -C o -o out
$ tpm2_flushcontext session.ctx

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
$ cd /tmp
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

## PKCS #11

Please refer to [[7]](#7).

# References

<a id="1">[1] https://www.infineon.com/cms/en/product/security-smart-card-solutions/optiga-embedded-security-solutions/optiga-tpm/</a><br>
<a id="2">[2] https://github.com/microsoft/ms-tpm-20-ref</a><br>
<a id="3">[3] https://github.com/tpm2-software/tpm2-tss</a><br>
<a id="4">[4] https://github.com/tpm2-software/tpm2-tools</a><br>
<a id="5">[5] https://github.com/tpm2-software/tpm2-tss-engine</a><br>
<a id="6">[6] https://github.com/Infineon/ek-based-onboarding-optiga-tpm</a><br>
<a id="7">[7] https://github.com/Infineon/pkcs11-optiga-tpm</a><br>
<a id="8">[8] https://www.infineon.com/dgdl/Infineon-OPTIGA_SLx_9670_TPM_2.0_Pi_4-ApplicationNotes-v07_19-EN.pdf?fileId=5546d4626c1f3dc3016c3d19f43972eb</a><br>

# License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.