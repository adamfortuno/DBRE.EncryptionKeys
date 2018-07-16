# DBRE.EncryptionKeys
## About
The purpose of this project is to assist consumers with retrieval and permissioning of Certificates and their associated private key. The module exposes functions allowing users to request keys and grant or revoke read permission to the certificate's primary key.

## Installation
To install this module, execute the following steps:

1. Open a Powershell session with administrative permissions.
2. Clone the project to a local directory of your choosing.
3. Navigate to the repository folder and run the ```install.ps1``` file.

That's it. The module will be installed to the machine's module directory.

This module works on traditional Windows systems. It will not work on Windows Core or Linux. This module depends on the following modules:

* ```ActiveDirectory```
* ```pki```

## Architecture

The module exposes three functions: Grant-AccessToCertificatePrivateKey(), Revoke-AccessToCertificatePrivateKey, and RequestMachineCertificate(). However, it hosts several helper functions used internally:

![Class Diagram](/documentation/class_diagram.png)

This repository is composed of the following

|File or Folder|Description|
---|---
|.\function|Stores the definition for all public and private functions.
|.\documentation|Stores images for this ReadMe.
|.\DBRE.EncryptionKeys.psd1|The module's manifest. Defines exported functions, modules version, and dependent modules.
|.\DBRE.EncryptionKeys.psm1|Module file. Loads the public and private functions in this module and initializes any global data members.
|.\DBRE.EncryptionKeys.psm1.Tests.ps1|Unit test script for this module.
|README.md|Read Me file for this project.
|.\install.ps1|Module installation script.
|.\manifest.txt|Module installation manifest. Tells the manifest what files and folders to copy on installation.

## Usage Examples

Request a certificate from the Active Directory Certificate Authority
using the WebServer2 template. Grant the 'MyDomain\svc-sql-eng01' read
permissions to the certificate's private key.

```Powershell
$certificate = Request-MachineCertificate `
    -CertificateRequestTemplateName 'WebServer2'

Grant-AccessToCertificatePrivateKey -Certificate $certificate `
    -Grantee 'MyDomain\svc-sql-eng01'
```

Select a certificate from the machine's certificate store and
revoke read permission from the certificate's private key from
'MyDomain\svc-sql-eng01'.

```Powershell
$certificate = $(ls 'cert:\LocalMachine\My' `
    | where { $_.HasPrivateKey -eq $true } | select -First 1)

Revoke-AccessToCertificatePrivateKey -Certificate $certificate `
    -Grantee 'MyDomain\svc-sql-eng01'
```