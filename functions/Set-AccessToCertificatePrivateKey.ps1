function Set-AccessToCertificatePrivateKey {
    <#
		.Synopsis
		Grants or revokes read access to a given private key.

		.Description
        This function grants or revokes read access to
        a given certificate's private key file on a specified
        account.
		
		.Parameter CertificatePrivateKeyPath
		The path to the private key file.

		.Parameter GranteeName
        The name of the system principal being granted access.

		.Parameter GrantReadAccess
        If present, indicates read access should be granted. If
        omitted (or false), indicates access should be revoked.

		.Example
        Set-AccessToCertificatePrivateKey `
            -CertificatePrivateKeyPath $certificate.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
			-GranteeName 'MyDomain\deezNutz'

        In this example, we're revoking read access to the given
        private key file from 'MyDomain\deezNutz'.

        .Example
        Set-AccessToCertificatePrivateKey `
            -CertificatePrivateKeyPath $certificate.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
            -GranteeName 'MyDomain\deezNutz' `
            -GrantReadAccess

        In this example, we're granting read access to the given
        private key file on 'MyDomain\deezNutz'.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)][string]$CertificatePrivateKeyPath
      , [Parameter(Mandatory=$true,Position=2)][string]$GranteeName
      , [Parameter(Mandatory=$false,Position=3)][switch]$GrantReadAccess
    )
    
    $permission = [System.Security.AccessControl.FileSystemRights]::Read
    $judgment = [System.Security.AccessControl.AccessControlType]::Allow

    $privatekey_file_permissions = Get-Acl -Path $CertificatePrivateKeyPath
    $access_rule = `
        New-Object System.Security.AccessControl.FileSystemAccessRule($GranteeName, $permission, 'None', 'None', $judgment)
    
    if ( $GrantReadAccess ) {
        $privatekey_file_permissions.AddAccessRule($access_rule)    
    } else {
        $privatekey_file_permissions.RemoveAccessRule($access_rule)
    }
    
    Set-Acl -Path $CertificatePrivateKeyPath -AclObject $privatekey_file_permissions
}