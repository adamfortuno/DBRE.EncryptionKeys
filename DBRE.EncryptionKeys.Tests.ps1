$test_script_path = Split-Path -Parent $MyInvocation.MyCommand.Path

$module_script_name = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", "")
$module_name = (Split-Path -Leaf $module_script_name).Replace(".psm1", "")

if ( Get-Module -Name $module_name ) {
    Remove-Module -Name $module_name
}

Import-Module "${test_script_path}" -Force -Scope Local
write-host $module_name

InModuleScope -ModuleName $module_name {
    Describe "Grant-AccessToCertificatePrivateKey" {
        $grantee = '<granteeName>'
        $certificate = New-Object 'System.Security.Cryptography.X509Certificates.X509Certificate2'
    
        Mock 'Test-RunAsAdministrator' { return $true }
        Mock 'Get-ADObject' { return $true }
        Mock 'Test-Path' { return $true }
        Mock 'Get-PrivateKeyPath' { return '<path>' }
        Mock 'Test-Path' { return $true }
        Mock 'Set-AccessToCertificatePrivateKey' {}
    
        context 'when the executing session is not elevated' {
            Mock 'Test-RunAsAdministrator' { return $false }

            It "should throw an exception" {
                { Grant-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee
                } | Should -Throw "elevated permissions"
            }
        }
            
    
        context 'when the account does not exist' {
            Mock 'Get-ADObject' { return $false }
    
            it 'should throw an exception' {
                { Grant-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee `
                } | Should -Throw "cannot be found"
            }
        }
    
    
        context 'when the private key file cannot be found' {
            Mock 'Test-Path' { return $false }
            
            it 'should throw an exception' {
                { Grant-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee `
                } | Should -Throw "Unable to find the private key file"
            }
        }
    
    
        context 'when called by an elevated session and all objects exist' {
            it "should set permission on the certificate's private key" {
                { Grant-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee `
                } | Should -Not -Throw
            }
        }
    }


    Describe "Request-MachineCertificate" {
        context 'when requesting a new certificate' {
            Mock 'Get-Certificate' `
                { return New-Object 'System.Security.Cryptography.X509Certificates.X509Certificate2' }
    
            It "Should complete successfully" {
                { Request-MachineCertificate | Out-Null } | Should -Not -Throw
            }
        }
    }
    

    Describe "Revoke-AccessToCertificatePrivateKey" {
        $grantee = '<granteeName>'
        $certificate = New-Object 'System.Security.Cryptography.X509Certificates.X509Certificate2'
    
        Mock 'Test-RunAsAdministrator' { return $true }
        Mock 'Get-ADObject' { return $true }
        Mock 'Test-Path' { return $true }
        Mock 'Get-PrivateKeyPath' { return '<path>' }
        Mock 'Test-Path' { return $true }
        Mock 'Set-AccessToCertificatePrivateKey' {}
    
        context 'when the executing session is not elevated' {
            Mock 'Test-RunAsAdministrator' { return $false }
            
            It "should throw an exception" {
                { Revoke-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee `
                } | Should -Throw "elevated permissions"
            }
        }
    
    
        context 'when the account does not exist' {
            Mock 'Get-ADObject' { return $false }
    
            it 'should throw an exception' {
                { Revoke-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee `
                } | Should -Throw "cannot be found"
            }
        }
    
    
        context 'when the private key file cannot be found' {
            Mock 'Test-Path' { return $false }
    
            it 'should throw an exception' {
                { Revoke-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee `
                } | Should -Throw "Unable to find the private key file"
            }
        }
    
    
        context 'when called by an elevated session and all objects exist' {
            it 'should ' {
                { Revoke-AccessToCertificatePrivateKey `
                    -Certificate $certificate `
                    -Grantee $grantee `
                } | Should -Not -Throw
            }
        }
    }
    

    Describe "Set-AccessToCertificatePrivateKey" {
        context 'when a private key file exists' {
            $permission = 'NT AUTHORITY\Authenticated Users Allow  Read, Synchronize'
            $privatekey_path = 'TestDrive:\privatekey.txt'
            $account_name = 'NT AUTHORITY\Authenticated Users'
    
            New-Item -Path $privatekey_path -ItemType File
    
            It "Should grant read rights to account" {
                Set-AccessToCertificatePrivateKey `
                    -CertificatePrivateKeyPath $privatekey_path `
                    -GranteeName $account_name `
                    -GrantReadAccess
    
                $file_access = Get-Acl -Path $privatekey_path
    
                $permission = $file_access.access | `
                    Where-Object { $_.AccessControlType -eq 'Allow' -and $_.FileSystemRights -eq 'Read, Synchronize' }
                
                ( $permission -eq $null ) | Should -Be $false
            }
            
            It "Should revoke read rights from account" {
                Set-AccessToCertificatePrivateKey `
                    -CertificatePrivateKeyPath $privatekey_path `
                    -GranteeName $account_name
    
                $file_access = Get-Acl -Path $privatekey_path
                
                $permission = $file_access.access | `
                    Where-Object { $_.AccessControlType -eq 'Allow' -and $_.FileSystemRights -eq 'Read, Synchronize' }
                    
                ( $permission -eq $null ) | Should -Be $true
            }
        }
    }
}