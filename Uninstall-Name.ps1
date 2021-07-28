<#
.SYNOPSIS
  Uninstall applications by name, using the uninstall / quietuninstall registry entries.
.DESCRIPTION
  Will always use the Quiet string if available, UNLESS the -IgnoreVendorSilentSwitches parameter is set to True. 
  In this event, the script will run the normal uninstall string found in registry. 
.PARAMETER SilentSwitches
  Silent switches to apply to the end of the normal registry uninstall string. 
  Generally not needed if a quiet uninstall string exists. 
.PARAMETER IgnoreVendorSilentSwitches
  If set to "True", will ignore the quietuninstall string and use normal uninstall string. 
  You should use the -SilentSwitches parameter in conjunction with this. 
.PARAMETER AppName
  The name of the application(s) you are trying to remove. 
  Please note that this script will loop through and attempt to remove ALL apps which match the "AppName" parameter. 
.NOTES
  Version:        1.0
  Author:         https://github.com/Arf-Echidna/
  Creation Date:  2021-07-28
  Purpose/Change: Initial script development
.EXAMPLE
  .\Uninstall-Name.ps1 -AppName 'Firefox' -SilentSwitches '/s'
  #>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)]
    [System.String]$AppName,
    [Parameter(Mandatory = $False)]
    [System.String]$SilentSwitches = $Null,
    [Parameter(Mandatory = $False)]
    [System.Boolean]$IgnoreVendorSilentSwitches = $False
)

$RegPath = Get-Childitem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty | Where-Object { $_.DisplayName -like "*$AppName*" }

ForEach ($ver in $RegPath) {
    If ($ver.QuietUninstallString -and $IgnoreVendorSilentSwitches -ne $True) {
        $uninst = $ver.QuietUninstallString
        Write-Host "Quiet string identified for $AppName as: `n $uninst" -ForegroundColor Green
    }
    else {
        $uninst = $ver.UninstallString
            
        if (!($SilentSwitches)) {
            Write-Host "WARNING - No quiet string identified for $AppName.  Will use normal string: `n $uninst" -ForegroundColor Red
            Write-Host "You may need to manually add silent switches to this uninstall, using the SilentSwitches parameter." -ForegroundColor Red
        }
            
    }
        
    Write-Host "Beginning removal with command line:  `n $uninst $SilentSwitches" -ForegroundColor Yellow
    Start-Process cmd -ArgumentList "/c $uninst $SilentSwitches" -NoNewWindow
}

