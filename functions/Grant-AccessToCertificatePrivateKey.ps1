function Grant-AccessToCertificatePrivateKey {
    <# 
		.Synopsis
		Grant read access from a given certificate's private key.

		.Description
        Grant read access to a given certificate's private key from
        a supplied account.
		
		.Parameter Certificate
		The subject certificate. 

		.Parameter GranteeName
        The name of the account being granted read permission on the
        certificate's private key.

        .Example
        $certificate = $(ls 'cert:\LocalMachine\My' `
            | where { $_.HasPrivateKey -eq $true } | select -First 1)
		Grant-AccessToCertificatePrivateKey -Certificate $certificate `
			-Grantee $(whoami)

        In this example, we have a x509 certificate in the $certificate
        variable. We're granting the executor read access to the 
        certificate's private key.
	#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)][System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
      , [Parameter(Mandatory=$true,Position=2)][string]$GranteeName
    )

    Write-Verbose 'Verify elevated permissions'
    if ( $(Test-RunAsAdministrator) -eq $false ) {
        throw "Please execute '$(${MyInvocation}.MyCommand)' with elevated permissions"
    }

    if ( $(Get-ADObject -Filter { CN -eq $GranteeName }) -eq $false ) {
        throw "The user or service account '${GranteeName}' cannot be found."
    }

    $privatekey_path = Get-PrivateKeyPath -Certificate $Certificate
    
    if ( $(Test-Path -Path $privatekey_path) -eq $false ) {
        throw "Unable to find the private key file '${privatekey_path}'. Verify the key file exists and you have rights to it."
    }

    Set-AccessToCertificatePrivateKey `
        -CertificatePrivateKeyPath $privatekey_path `
        -GranteeName $GranteeName `
        -GrantReadAccess
}