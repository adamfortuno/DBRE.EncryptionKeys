function Get-PrivateKeyPath {
    <# 
		.Synopsis
		Get Private Key Path

		.Description
        Retrieves the location on disk of a certificate's private
        key.
		
		.Parameter Certificate
		The certificate associated with the subject private key.

		.Example
        $certificate = $(ls 'cert:\LocalMachine\My' | where { $_.HasPrivateKey -eq $true } | select -First 1)
        Get-PrivateKeyPath -Certificate $certificate
	#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)][System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )

    if ( $certificate.HasPrivateKey -eq $false ) {
        throw "Certificate does not have a private key."
    }

    if ( $certificate.PrivateKey -ne $Null ) {
        Write-Verbose "Private Key is a CSP Provider"

        $privatekey = $certificate.PrivateKey
        $privatekey_file_name = $privatekey.CspKeyContainerInfo.UniqueKeyContainerName
        $privatekey_path = Get-ChildItem "${env:ProgramData}\Microsoft\Crypto\RSA\MachineKeys\${privatekey_file_name}"
    } elseif ( [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate) ) {
        Write-Verbose "Private Key is a CNG Provider"

        $privatekey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)
        $privatekey_file_name = $privatekey.key.UniqueName
        $privatekey_path = ${privatekey_file_name}
    } else {
        throw "Unable to retrieve the certificate's private key."
    }

    return $privatekey_path
}