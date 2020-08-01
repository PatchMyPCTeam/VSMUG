function Get-ManagedDeviceDetectedApps {
    <#
    .SYNOPSIS
        Return a list of detected apps from a graph managedDevice
    .DESCRIPTION
        This function expands the detectedApps property of a managedDevice in MS Graph. You can optionally privde
        an ApplicationFilter which is used to perform a regex max on the application name
    .PARAMETER DeviceId
        An array of DeviceId you wish to search for applications on. This accepts pipeline input based on propoerty name
        so anything that returns your device Ids under the property name of Id or DeviceId can be piped to this function
    .PARAMETER ApplicationFilter
        An array of strings that will be evaluated as a regex match to find applications on the devices
    .PARAMETER AuthHeader
        Your authentication header to MS Graph
    .EXAMPLE
        C:\PS> $alld | Get-ManagedDeviceDetectedApps -ApplicationFilter 'Chrome' -AuthHeader $headers
            Return all applications that match the 'Chrome' filter from the $Alld list of devices
    .EXAMPLE
        C:\PS> $alld | Get-ManagedDeviceDetectedApps-AuthHeader $headers
            Return all applications from all devices in $alld with no filter applied
    .EXAMPLE
        C:\PS> $alld | Get-ManagedDeviceDetectedApps -ApplicationFilter 'Chrome','Edge' -AuthHeader $headers
            Return all applications that match the 'Chrome' or 'Edge' filter from the $Alld list of devices
    #>
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [string[]]$DeviceId,
        [parameter(Mandatory = $false )]
        [Alias('Application', 'App', 'AppName', 'ApplicationName')]
        [string[]]$ApplicationFilter,
        [parameter(Mandatory = $true)]
        [hashtable]$AuthHeader
    )
    begin {
        # Just a placeholder so we can leverage the pipeline :)
    }
    process {
        foreach ($Device in $DeviceId) {
            $DeviceAppURI = [string]::Format('deviceManagement/managedDevices/{0}?$expand=detectedApps', $Device)
            $DeviceFromGraph = Get-MsGraphData -Endpoint $DeviceAppURI -AuthHeader $AuthHeader
            $AllDetectedAppsOnDevice = $DeviceFromGraph.detectedApps
            foreach ($DetectedApplication in $AllDetectedAppsOnDevice) {
                switch ($PSBoundParameters.ContainsKey('ApplicationFilter')) {
                    $true {
                        foreach ($AppFilter in $ApplicationFilter) {
                            switch -Regex ($DetectedApplication.displayname) {
                                $AppFilter {
                                    [pscustomobject]@{
                                        ComputerName   = $DeviceFromGraph.deviceName
                                        AppDisplayName = $DetectedApplication.displayname
                                        AppVersion     = $DetectedApplication.version
                                    }
                                }
                            }
                        }
                    }
                    $false {
                        [pscustomobject]@{
                            ComputerName   = $DeviceFromGraph.deviceName
                            AppDisplayName = $DetectedApplication.displayname
                            AppVersion     = $DetectedApplication.version
                        }
                    }
                }
            }
        }
    }
}