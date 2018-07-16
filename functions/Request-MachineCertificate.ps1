function Request-MachineCertificate {
    <#
		.Synopsis
		Requests a machine certificate from the AD Certificate Authority

		.Description
        This function requests a certificate from the domain's certificate 
        authority. Certificates are stored in the 'Cert:\LocalMachine\My'
        store.

		.Parameter CertificateRequestTemplateName
        The name of a certificate template to be used. Defaults to
        'ComcastComputer'.

		.Example
        $certificate = Request-MachineCertificate `
            -CertificateRequestTemplateName 'WebServer2'
        
        In this example, we request a machine certificate using the
        WebServer2 template.

        .Example
        $certificate = Request-MachineCertificate

        In this example, we request a certificate with the default
        template.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,position=1)][string]$CertificateRequestTemplateName
      , [Parameter(Mandatory=$false,position=2)][string[]]$SubjectAlternateNames
    )

    $certificate_request_host_fqdn = `
        'CN = {0}' -f [System.Net.Dns]::GetHostByName($env:computerName).Hostname
    $certificate_request_location = 'Cert:\LocalMachine\My'
    
    ## Request the certificate from the AD Cert Authority
    $certificate_request = Get-Certificate `
        -Template $CertificateRequestTemplateName `
        -CertStoreLocation $certificate_request_location `
        -SubjectName $certificate_request_host_fqdn `
        -DnsName $SubjectAlternateNames
        
    return $certificate_request
}