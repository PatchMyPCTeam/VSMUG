function Get-ManagedDevices {
    <#
    .SYNOPSIS
        Get all managed devices in the users Intune environment via graph
    .DESCRIPTION
        Uses the Microsoft Graph to query the deviceManagement/managedDevices endpoint and return all devies
    .PARAMETER AuthHeader
        The authentication hearders to access Microsoft Graph. These can be created using the Get-AuthToken function
    .EXAMPLE
        C:\PS> $alld = Get-ManagedDevices -AuthHeader $headers
            Get all devices using the auth headers provided
    #>
    param (
        [parameter(Mandatory = $true)]
        [hashtable]$AuthHeader
    )
    Get-MsGraphData -Endpoint 'deviceManagement/managedDevices' -AuthHeader $AuthHeader    
}