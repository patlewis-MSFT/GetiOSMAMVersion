#####################################################################
# GetiOSMAMVersion
#
# Gathers the version of the Intune Wrapper used with the application
#
# Parameters:
#    -path : The full path and name of the wrapped .ipa file
#    -help : Displays usage and help
#
# Usage:
#    .\GetiOSMAMVersion.ps1 -path <path and filename>
#    .\GetiOSMAMVersion.ps1 -help
#
# Example:
#    .\GetiOSMAMVersion.ps1 -path "C:\LOBApps\MyApp.ipa"
#
# Author: Patrick Lewis
# Update: Version 1.0  1/24/2020
#####################################################################
param (
    [string]$path = "",
    [switch]$help
)

function CheckParmeters ()
{
    if ($help)
    {
        PrintHelp
        exit
    }
    if ($path.Length -eq 0)
    {
        Write-Host "Error: The input file is empty"
        Write-Host
        PrintHelp
        exit
    }

    $path = $path.Trim()

    if ((Test-Path $path) -eq $false)
    {
        Write-Host
        Write-Host "Error: The input file or path is invalid."
        Write-Host
        exit
    }
}

function PrintHelp ()
{
    Write-Host "*******************************************************************"
    Write-Host "GetiOSMAMVersion"
    Write-Host "*******************************************************************"
    Write-Host "Gathers the version of the Intune Wrapper used with the application"
    Write-Host 
    Write-Host "Parameters:"
    Write-Host "    -path : The full path and name of the wrapped .ipa file"
    Write-Host "    -help : Displays usage and help"
    Write-Host
    Write-Host "Usage:"
    Write-Host "    .\GetiOSMAMVersion.ps1 -path <path and filename>"
    Write-Host "    .\GetiOSMAMVersion.ps1 -help"
    Write-Host 
    Write-Host "Example:"
    Write-Host "   .\GetiOSMAMVersion.ps1 -path C:\LOBApps\MyApp.ipa"
    Write-Host
}

CheckParmeters

Add-type -Assemblyname "System.IO.Compression" -PassThru | Select-Object -ExpandProperty Assembly | Select-Object FullName -Unique | Out-Null
Add-type -Assemblyname "System.Xml" -PassThru | Select-Object -ExpandProperty Assembly | Select-Object FullName -Unique | Out-Null

$PathDefaultZip = "C:\WINDOWS\Microsoft.Net\assembly\GAC_MSIL\System.IO.Compression.ZipFile\v4.0_4.0.0.0__b77a5c561934e089\System.IO.Compression.ZipFile.dll"
Add-type -Path $PathDefaultZip | Out-Null

$MAMVersionString = "IntuneMAMBuildBranch"

$zipPath = $path

try
{
    $zipToOpen = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Read)
}
catch [System.Management.Automation.RuntimeException]
{
    Write-Host
    Write-Host "File or path is invalid" -ForegroundColor Red
    Write-Host
    PrintHelp
    exit
}

$WrapperFound = $false

$zippedInfoPlist = $ziptoopen.Entries | Where-Object FullName -CLike "*Frameworks/IntuneMAM.framework/Info.plist"

if ($null -eq $zippedInfoPlist)
{
    $zippedInfoPlist = $ziptoopen.Entries | Where-Object FullName -CLike "*Frameworks/IntuneMAMSwift.framework/Info.plist"
    if ($null -eq $zippedInfoPlist)
    {
        Write-Host "The .ipa has not been wrapped with the Intune Wrapper"
        exit
    }
}

$streamReader = [System.IO.Stream]$zippedInfoPlist.Open()
$xmlReader = New-Object System.Xml.XmlDocument

#The info.plist may be a binary property list instead of xml/text
try 
{
    $xmlReader.Load($streamReader)
}
catch
{
    Write-Host "Unable to read Info.list"
    Write-Host "The file could be in binary property list format which this utility does not support."
    exit
}

    $xmlNode = $xmlReader.DocumentElement.ChildNodes[0]
    $xmlNodes = $xmlNode.ChildNodes


    for ($index = 0; $index -lt $xmlNodes.Count; $index++)
    {
        if ($xmlNodes[$index].'#text' -eq $MAMVersionString)
        {
            $BuildNumber = ($xmlNodes[$index + 1].'#text')
            $BuildNumber = $BuildNumber.SubString($BuildNumber.LastIndexOf("/") + 1)
            Write-Host "******************************************"
            Write-Host "Using IntuneMAM Wrapper version: " $BuildNumber
            Write-Host "******************************************"
            $WrapperFound = $true
        }
    }

    if ($WrapperFound -eq $false)
    {
        Write-Host "The .ipa has not been wrapped with the Intune Wrapper"
    }
