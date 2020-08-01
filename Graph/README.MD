#### Basic Graph Queries

This folder contains some simple examples of querying Microsoft Graph for data.

Generally, you will get your authentication token first using the Get-AuthToken function, for example:

```powershell
$AuthHeaders = Get-AuthToken -User Joe@Contoso.com
```

Once you have an authentication token you are able to use it to query for data. 

```powershell
$AllDevices = Get-ManagedDevices -AuthHeader $AuthHeaders
```

And depending on how you write your functions, you can start to leverage the pipeline of PowerShell!

```powershell
$AllDevices | Get-ManagedDeviceDetectedApps -ApplicationFilter 'Chrome','Edge' -AuthHeader $AuthHeaders
```

It is good to note that the Get-ManagedDevices and Get-ManagedDeviceDetectedApps both rely on the Get-MsGraphData function. This function ultimately does the Invoke-RestMethod against the Graph API to return data with a Get method. The plain code to do a graph query via PowerShell might look something like below.

```powershell
Invoke-RestMethod -Method Get -Uri https://graph.microsoft.com/beta/deviceManagement/managedDevices -Headers $AuthHeader
```

The functions are just a wrapper to simplify grabbing some standard bits of information and creating more familiar commands to be run.
