Function Get-AuthToken {
    <#
        .SYNOPSIS
            This function is used to authenticate with the Graph API REST interface
        .DESCRIPTION
            The function authenticate with the Graph API Interface with the tenant name
        .PARAMETER User
            The user to get a token for. This should include the tenant name / mail domain
        .EXAMPLE
            C:\PS> $Header = Get-AuthToken -User Joe@Contoso.com
                Generates an authentication header and stores it in the $Header variable
                so that it can be passed to functions that require authentication to graph
        .NOTES
            Handful of variations out there for this function. They all achieve the same end goal :)
    #>
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [mailaddress]$User
    )

    $tenant = $User.Host

    $AadModule = Get-Module -Name "AzureAD" -ListAvailable
    if (-not $AadModule) {
        $AadModule = Get-Module -Name "AzureADPreview" -ListAvailable
    }

    if (-not $AadModule) {
        Write-Host
        throw("AzureAD Powershell module not installed..`n" +
            "Install by running 'Install-Module AzureAD' or 'Install-Module AzureADPreview' from an elevated PowerShell prompt")
    }

    # Getting path to ActiveDirectory Assemblies
    # If the module count is greater than 1 find the latest version
    if ($AadModule.count -gt 1) {
        $Latest_Version = ($AadModule | Select-Object version | Sort-Object)[-1]
        $aadModule = $AadModule | Where-Object { $_.version -eq $Latest_Version.version }

        # Checking if there are multiple versions of the same module found
        if ($AadModule.count -gt 1) {
            $aadModule = $AadModule | Select-Object -Unique
        }

        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"

    }
    else {
        $adal = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = Join-Path $AadModule.ModuleBase "Microsoft.IdentityModel.Clients.ActiveDirectory.Platform.dll"
    }

    $null = [System.Reflection.Assembly]::LoadFrom($adal)
    $null = [System.Reflection.Assembly]::LoadFrom($adalforms)
    $clientId = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"
    $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
    $resourceAppIdURI = "https://graph.microsoft.com"
    $authority = "https://login.microsoftonline.com/$Tenant"

    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
    $platformParameters = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.PlatformParameters" -ArgumentList "Auto"
    $userId = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.UserIdentifier" -ArgumentList ($User, "OptionalDisplayableId")
    $authResult = $authContext.AcquireTokenAsync($resourceAppIdURI, $clientId, $redirectUri, $platformParameters, $userId).Result

    # If the accesstoken is valid then create the authentication header
    if ($authResult.AccessToken) {
        # Creating header for Authorization token
        $authHeader = @{
            'Content-Type'  = 'application/json'
            'Authorization' = "Bearer " + $authResult.AccessToken
            'ExpiresOn'     = $authResult.ExpiresOn
        }
        return $authHeader
    }
    else {
        throw "Authorization Access Token is null, please re-run authentication..."
    }
}