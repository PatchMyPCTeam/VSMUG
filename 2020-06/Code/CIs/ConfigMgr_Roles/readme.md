Here you will find an export of Configuration Items, and Configuration Baselines that will assist with configuring various Configuration Manager Site System roles.

If a CI has "(Define Variable)" in the name, this means you need to open up the script and define a variable to work for your environment. Don't forget to edit both the detection, and the remediation!

The 'ConfigMgr: Site System' configuration baseline is intended for all site systems, and includes settings such as ensuring NO_SMS_ON_DRIVE.SMS exists where needed, and remote registry is enabled for example.

The SSL configurations for a SUP / WSUS is intended to configure, or fix a WSUS server that has had configuressl ran already. [WSUSUtil ConfigureSSL](https://docs.microsoft.com/en-us/windows-server/administration/windows-server-update-services/deploy/2-configure-wsus#to-configure-ssl-on-the-wsus-root-server) sets up the WSUS instance to be ready for SSL, and then the CB can come back through and setup, or fix the configuration. Below is the 'Applicability' for the WSUS SSL CIs. We check if IIS is installed, then validate the 'ServerCertificateName' property has a value matching the computer name, and the server is set to use SSL. 

```ps
try {
    [Void][Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")
    $serverManager = New-Object Microsoft.Web.Administration.ServerManager -ErrorAction SilentlyContinue
}
catch {
    # Deliberate empty return. If anything above throws an error, we assume we are not on a box with IIS
    exit 0
}

$WSUS_ConfigKey = 'registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Update Services\Server\Setup'

try {
    $ServerCertName = Get-ItemPropertyValue -Path $WSUS_ConfigKey -Name 'ServerCertificateName' -ErrorAction Stop
    $UsingSSL = Get-ItemPropertyValue -Path $WSUS_ConfigKey -Name 'UsingSSL' -ErrorAction Stop
    if ($serverManager.ApplicationPools.Name -contains 'WsusPool' -and $env:COMPUTERNAME -match $ServerCertName -and $UsingSSL) {
        Write-Host 'WSUS Server is SSL'
    }
}
catch {
    # Deliberate empty return. If anything above throws an error, we assume we are not on an SSL WSUS box
    exit 0
}```


I will try to add to the Readme with any notes regarding these, but wanted to at least get them up here!
