# The goal of this script is to clean up unneeded third party updates from a configmgr environment
# 1. Choose a catalog to clean up
# 2. Choose categories to KEEP
# 3. Decline all updates for the publisher of that catalog, that are not in the selected categories, as well as updates that no longer exist

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "DM3" # Site code 
$ProviderMachineName = "DEMO3.CONTOSO.LOCAL" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if ((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

# Get the currently enabled catalogs
$AllCatalogs = Get-CMThirdPartyUpdateCatalog
$EnabledCatalogs = $AllCatalogs | Where-Object SyncEnabled -EQ $true | Select-Object Name, PublisherName, Description, SyncEnabled, LastSyncStatus, DownloadUrl

if ($EnabledCatalogs) {
    #Catalogs are enabled Choose Catalog to clean
    $SelectedCatalog = $EnabledCatalogs | Out-GridView -Title "Select the catalog to clean" -OutputMode Single

}
elseif ($AllCatalogs) {
    # No Catalogs are enabled Choose from the available catalogs in the Console
    $SelectedCatalog = $AllCatalogs | Out-GridView -Title "Select the catalog to clean" -OutputMode Single


}
else {
    # TODO No catalogs are in the console, get them from the source
    Exit 1

}

if ($SelectedCatalog) {
    # Download the catalog
    $TempDLPath = "$env:Temp\$(New-Guid)"
    New-Item -ItemType Directory -Path $TempDLPath -Force -ErrorAction SilentlyContinue | Out-Null
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -Uri $SelectedCatalog.DownloadUrl -OutFile "$TempDLPath\Catalog.cab"

    # Extract the catalog
    $expand = Start-Process expand.exe -ArgumentList "`"$TempDLPath\Catalog.cab`" -F:*.xml `"$TempDLPath`"" -Wait -NoNewWindow -PassThru
    $expand = Start-Process expand.exe -ArgumentList "`"$TempDLPath\Catalog.cab`" -F:*.json `"$TempDLPath`"" -Wait -NoNewWindow -PassThru
    Write-Host "Importing Catalog, this may take some time..."
    [xml]$CatalogXML = Get-Content -Path (Get-Item "$TempDLPath\*.xml")


    # A Catalog Has been selected See if any categories are enabled in ConfigMgr
    $EnabledCategories = (Get-CMThirdPartyUpdateCategory -CatalogName $SelectedCatalog.Name | Where-Object { $_.PublishOption -ne 0 -and (-not [System.String]::IsNullOrEmpty($_.ParentId)) }).Id
    $EnabledCategories1 = $EnabledCategories
    if ($EnabledCategories) {
        $CleanConsoleSelected = [System.Windows.MessageBox]::Show("Clean old updates and updates in categories not selected for sync in ConfigMgr for publisher $($SelectedCatalog.PublisherName)?`r`n`r`nYes: Decline updates not selected for sync in ConfigMgr`r`n`r`nNo: Choose update categories to keep", "Clean $($SelectedCatalog.PublisherName) Updates?", 'YesNo', 'Question')
    }
    else {
        Remove-Variable -Name "CleanConsoleSelected" -ErrorAction silentlycontinue
    }

    if ($CleanConsoleSelected -ne "Yes") {
        # select categories
        $EnabledCategories = Get-ChildItem $TempDLPath\V3 | Where-Object { (($_.Name).replace(".json", "") -as [guid]) -is [guid] } | ForEach-Object {
            (Get-Content $_.FullName | ConvertFrom-Json) 
        } | Select-Object DisplayName, ParentID, ID, Members | Sort-Object -Property ParentId | Out-GridView -Title "Select Categories to KEEP" -OutputMode Multiple
        $enabledCategoriesTemp = ($EnabledCategories | Where-Object { [System.String]::IsNullOrEmpty($_.ParentId) }).Members
        $enabledCategoriesTemp += ($EnabledCategories | Where-Object { -not [System.String]::IsNullOrEmpty($_.ParentId) }).Id
        $EnabledCategories = $enabledCategoriesTemp
        $EnabledCategories2 = $EnabledCategories | Sort-Object
    } 

    #Gather the updates in the selected categories
    $SelectedUpdates = Get-ChildItem $TempDLPath\V3 | Where-Object { (($_.Name).replace(".json", "")) -in $EnabledCategories } | ForEach-Object {
        (Get-Content $_.FullName | ConvertFrom-Json) 
    } | Select-Object DisplayName, ParentID, ID, Members
    $SelectedUpdateIds = ($SelectedUpdates.Members | Select-Object -Unique)

    #Gather all the updates for this catalog that are currently published and not declined
    $Publisher = $CatalogXML.SystemsManagementCatalog.SoftwareDistributionPackage.Properties.VendorName | Select-Object -Unique
    $WSUSUpdatestoRemove = Get-WsusUpdate -Approval AnyExceptDeclined | Where-Object { ($_.Update.CompanyTitles -contains $Publisher) -and ($_.UpdateId -notin $SelectedUpdateIds) }
    #$WSUSUpdatestoRemove

    #Cleanup
    if (Test-Path $TempDLPath -ErrorAction SilentlyContinue) {
        Remove-Item $TempDLPath -Force -Recurse
    }

    #Decline the rest of the updates
    $CleanUpdates = [System.Windows.MessageBox]::Show("$($WSUSUpdatestoRemove.count) updates from $($SelectedCatalog.PubisherName) will be declined in WSUS, Continue?`r`n`r`nYes: Decline all Updates Now`r`n`r`nNo: Show all updates before declining`r`n`r`nCancel: Do not decline updates", "Clean $($WSUSUpdatestoRemove.Count) for $($SelectedCatalog.PublisherName)?", 'YesNoCancel', 'Question')
    Switch ($CleanUpdates) {
        'Yes' {
            $CleanUpdates = $true
        }
        'No' {
            $GridViewUpdates = $WSUSUpdatestoRemove | Out-GridView -Title "Updates to be declined | Choose Cancel to skip update decline" -OutputMode Single
            if ($GridViewUpdates) {
                $CleanUpdates = $true
            }
            else {
                Exit 0
            }
        }
        'Cancel' {
            Exit 0
        }
        default {
            Exit 0
        }
    }

    if ($CleanUpdates) {
        Write-Host "Declining $($WSUSUpdatestoRemove.Count) updates"
        $WSUSUpdatestoRemove | Deny-WsusUpdate -Confirm:$false
    }

}


