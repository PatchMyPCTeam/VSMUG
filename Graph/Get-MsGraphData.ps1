Function Get-MsGraphData {
    <#
        .SYNOPSIS
            Perform a graph query against the array of endpoints
        .DESCRIPTION
            Function to perform a graph query against the array of provided endpoints. You can specify the version
            of graph to use, either Beta, or v1.0. 
        .PARAMETER Endpoint
            The string array of graph endpoints to query against, such as 'deviceManagement/managedDevices'
        .PARAMETER AuthHeader
            The authentication hearders to access Microsoft Graph. These can be created using the Get-AuthToken function
        .PARAMETER GraphVersion
            Either the Beta, or the v1.0 graph version. This defaults to beta. Use whatever works best for the queries you are performing
            Officially, Microsoft states that the beta is not for production use
        .EXAMPLE 
            C:\PS> Get-MsGraphData -Endpoint 'deviceManagement/managedDevices' -AuthHeader $Header
    #>
    param(
        [parameter(Mandatory = $true)]
        [string[]]$Endpoint,
        [parameter(Mandatory = $true)]
        [hashtable]$AuthHeader,
        [parameter(Mandatory = $false)]
        [ValidateSet('Beta', 'v1.0')]
        [string]$GraphVersion = 'Beta'

    )
    begin {
        $RootURI = [string]::Format("https://graph.microsoft.com/{0}", $GraphVersion)
    }
    process {
        foreach ($EP in $Endpoint) {
            $NextLink = [string]::Format('{0}/{1}', $RootURI, $EP)

            do {
                $Result = Invoke-RestMethod -Method Get -Uri $NextLink -Headers $AuthHeader
                if ($null -ne $Result.'@odata.count') {
                    foreach ($object in $Result.value) {
                        Write-Output $object
                    }
                }
                else {
                    Write-Output $Result
                }
                $NextLink = $Result.'@odata.nextLink'
            } while ($null -ne $NextLink)
        }
    }
}
