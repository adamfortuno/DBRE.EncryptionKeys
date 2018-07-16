function Test-RunAsAdministrator {
	<#
		.Synopsis  
		Verify the current session has elevated priviledges.

		.Description
		This commandlet confirms that the session's context has
		elevated permissions.

		.Example
		Test-RunAsAdministrator
	#>

	$current_context = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	return $current_context.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}