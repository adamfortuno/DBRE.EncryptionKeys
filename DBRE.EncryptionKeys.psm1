Set-StrictMode -Version 4.0

<#
    .Synopsis
    Module Root Script

    .Description
    This is the root script for this module. This script
    is a bootstrap loader, loading the rest of the module,
    and setting its initial state.
    
    This script will load the various function files from
    the function directory.
#>

$module_file_path = $script:MyInvocation.MyCommand.Path
$module_directory_path = Split-Path -Path $module_file_path -Parent
$module_function_directory_path = Join-Path -Path $module_directory_path -ChildPath 'functions'

## This will import/load functions from functions directory
$module_scripts = `
    Get-ChildItem -Path "${module_function_directory_path}\*" `
        -Include '*.ps1' `
        -Exclude '*.Tests.ps1'

foreach ( $script in $module_scripts ) {
	. $script
}