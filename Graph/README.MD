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
