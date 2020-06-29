param(
	# Set the Display Name to Search
	[Parameter()]
	[String]
	$UserAppToSearch = "*",
	# Set the Publisher to Search
	[Parameter()]
	[String]
	$PublisherToSearch = "*"
)

$UserAppFound = Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall -Recurse | Get-ItemProperty | Where-Object { ($_.Publisher -like $PublisherToSearch) -and ($_.DisplayName -like $UserAppToSearch) } | Select-Object Displayname, UninstallString

If ($UserAppFound) {
	Write-Output "INSTALLED"
}
Else {
	Write-Output "NOT-INSTALLED"
}