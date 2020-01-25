# GetiOSMAMVersion
Gets the version of the Intune App Wrapping Tool used with the application (.ipa)

Author: Patrick Lewis
Update: Version 1.0  1/24/2020


## Prerequisites
* Windows device with PowerShell
* Valid iOS application that has been wrapped with the Intune App Wrapping Tool

## Getting Started
1. Download GetiOSMAMVersion.ps1 to your Windows 10 device
1. Run .\GetiOSMAMVersion.ps1

Parameters:
   -path : The full path and name of the wrapped .ipa file
   -help : Displays usage and help

Usage:
   .\GetiOSMAMVersion.ps1 -path <path and filename>
   .\GetiOSMAMVersion.ps1 -help

Example:
   .\GetiOSMAMVersion.ps1 -path "C:\LOBApps\MyApp.ipa"

## More information on the Intune Wrapping Tool
* https://docs.microsoft.com/en-us/intune/developer/app-wrapper-prepare-ios
* https://github.com/msintuneappsdk/intune-app-wrapping-tool-ios
