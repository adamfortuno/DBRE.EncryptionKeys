Set-StrictMode -version 4.0

$ErrorActionPreference = 'Stop'

## Initialize variables
$directory_install_script = Split-Path -Parent $MyInvocation.MyCommand.Path

[Security.Principal.WindowsPrincipal]$my_role = [Security.Principal.WindowsIdentity]::GetCurrent()
$system_role_administrator = [Security.Principal.WindowsBuiltInRole]::Administrator
$default_modules_directory = "C:\Program Files\WindowsPowerShell\Modules\"
$default_powershell_minimum_version = 4

$target_module_name = 'DBRE.EncryptionKeys'
$target_module_metadata = Test-ModuleManifest -Path "${target_module_name}.psd1"
$target_module_version = $target_module_metadata.version
$target_module_files = $(Get-Content -Path '.\manifest.txt')
$target_module_directory = Join-Path -Path $default_modules_directory -ChildPath $target_module_name
$target_module_install_directory = Join-Path -Path $target_module_directory -ChildPath $target_module_version

if ( $PSVersionTable.PSVersion.Major -lt 4 ) {
    Write-warning "'${target_module_name}' is supported with Powershell ${default_powershell_minimum_version} or later."
}

if ( [bool]$(Get-Module -ListAvailable -Name ActiveDirectory) -eq $false) {
    Write-warning "'${target_module_name}' requires the ActiveDirectory Powershell modules."
}

Write-Output "Installation Directiory:`t${directory_install_script}"
Write-Output "Target Directory: `t`t${default_modules_directory}"
Write-Output 'Starting Installation'

try {
    if ( $my_role.IsInRole($system_role_administrator) -eq $false ) {
        throw 'Please run this script with elevated permissions.'
    }

    if ( Test-Path -Path $target_module_install_directory ) {
        Write-Output "...removing '${target_module_install_directory}'"
        Remove-Item -Path $target_module_install_directory -Force -Recurse
    }

    ## Create the target module's directory in the system's module folder
    Write-Output "...creating '${target_module_install_directory}'"
    New-Item -Path $target_module_directory `
        -Name $target_module_version `
        -ItemType Directory `
        -Force | Out-Null
    
    ## Copy all module files to it's directory
    foreach ( $module_file in Resolve-Path $target_module_files) {
        $module_file_path_relative = Resolve-Path -Path $module_file -Relative

        $module_file_path_relative_parent = Resolve-Path $module_file_path_relative -Relative | Split-Path -Parent
    
        if ( $module_file_path_relative_parent -eq '.' ) {
            $installation_path = $target_module_install_directory
        } else {
            $parent_folder_name = Split-Path -Path $module_file_path_relative_parent -Leaf
            $installation_path = Join-Path -Path $target_module_install_directory -ChildPath $parent_folder_name
        }

        Write-Output "...copying '${module_file_path_relative}' to '${installation_path}'"
        Copy-Item -Path $module_file_path_relative -Destination $installation_path -Force
    }

    Import-Module $target_module_name -Force

    Write-Output 'Installation Complete'
} catch {
    throw $_.Exception
}

