<#
.SYNOPSIS
Delete-Apps.ps1 - PowerShell script to detect Windows Apps and delete/installs it.

.DESCRIPTION 
This PowerShell script will try to get the AppxPackage and delete or install the application 
on your Windows 8, Windows 8.1 or Windows 10 device. You will need to execute on some devices 
the following PowerShell command: "Set-ExecutionPolicy RemoteSigned" - this will ensure you 
have enough privileges to delete those apps. Also you have the ability to delete system Apps,
where we don't have in our Database.ps1 - Support us and send us your list of Apps: 
"Get-AppxPackage | Select Name" in PowerShell and send us the output or you can directly save 
in a text file with the following command: 
"Get-AppxPackage | Select Name >> $env:userprofile\Desktop\Windows-Apps_$(gc env:computername).txt"

.EXAMPLE
.\Delete-Apps.ps1

.OUTPUT
NONE

.PARAMETER LANG CODE (2 Letter ISO Code)
You can also switch the language by .\Delete-Apps.ps1 DE (for German)
Currently supported languages DE,FR,EN

.NOTES
Written by Sascha Sebastian Helfinger - sascha.sebastian.helfinger@shelfinger.com, sh@shelfinger.eu
Technical Consultant/Director at SHelfinger Sarl - https://shelfinger.eu, http://shelfinger.com

You can also find me on:

* Twitter: https://twitter.com/shelfinger
* LinkedIn: http://tg.linkedin.com/in/shelfinger/
* Github: https://github.com/shelfinger
* Facebook: https://facebook.com/SHelfinger.EU

License:

The MIT License (MIT)

Copyright (c) 2016 Sascha Sebastian Helfinger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Change Log:
V1.00, 31/05/2016 - First release
V1.01, 02/06/2016 - Database updatable function included
V1.02, 03/06/2016 - Language (DE, FR, EN) and updatable function included
V1.03, 04/06/2016 - Added the Global Package delete function
#>


[CmdletBinding()]

Param (

    [parameter(ValueFromPipeline=$True)]
    [string[]]$language

)
$ComputerName = $(gc env:computername)
$Logfile = "$PSScriptRoot\$ComputerName.log"
$database_file = "$PSScriptRoot\Database.ps1"
$WindowsSupported = 0
$PowerShellMinimumVersion = "2.0.0"
$PowerShellVersion = $PSVersionTable.PSVersion
$ScriptVersion = "1.02"

Function LogWrite {
   Param ([string] $logstring)
   $date = Get-Date -format G
   Add-content $Logfile -value "$date - $logstring"
}
Function Get-Database {
    $url = "https://shelfinger.eu/development/windows/Delete-Apps/Database.ps1"
    $output = "$PSScriptRoot\Database.ps1"
    Start-BitsTransfer -Source $url -Destination $output
    return
}
Function Get-OSVersion {
    $signature = @"
 [DllImport("kernel32.dll")]
 public static extern uint GetVersion();
"@
    Add-Type -MemberDefinition $signature -Name "Win32OSVersion" -Namespace Win32Functions -PassThru
}

$OSVersion = [System.BitConverter]::GetBytes((Get-OSVersion)::GetVersion())
$OSString = $OSVersion[0], $OSVersion[1]

if ($language) { $Lang = $language }
else { 
    $tmp = Get-Culture 
    $Lang = $tmp.TwoLetterISOLanguageName
}

if(![System.IO.File]::Exists($database_file)){
    LogWrite "================= Downloading Database ================="
    LogWrite "Database not found, downloading new Database."
    Get-Database
    . $database_file
    LogWrite "Downloaded the Database and can be found now in $database_file"
} else {
    LogWrite "================= Checking Database ================="
    $lastWrite = (get-item $database_file).LastWriteTime
    $timespan = new-timespan -days 7
    if (((get-date) - $lastWrite) -gt $timespan) {
        LogWrite "File is: $(((get-date) - $lastWrite).TotalDays) days old."
        Remove-Item $database_file
        Get-Database
    } else {
        LogWrite "Database file found and not older than 7 days."
        . $database_file
    }
}

Foreach ($v in $versions) {
    if ($v[2] -eq $OSString) {
        $gversionn = $v[0]
        $gversionm = $v[1]
        $gversioni = $v[2]
        $WindowsSupported = 1
    } 
}
if ([version]$PowerShellVersion -lt [version]$PowerShellMinimumVersion) {
    $WindowsSupported = 0
}
if ($WindowsSupported -eq 0) { 
    Write-Host "Your Windows Version ($OSVersion) is currently not supported from this PowerShell Script."
    Write-Host "- Please check that you have the latest Database.ps1 file in your Script dir ($PSScriptRoot) with Version ($DatabaseVersion)"
    Write-Host "- Please check that your PowerShell Version is upper than V$PowerShellMinimumVersion (V$PowerShellVersion)"
    Write-Host "- Also visit https://shelfinger.eu for a newer version of Delete-Apps.ps1 currently ($ScriptVersion)"
    Exit
}

Foreach ($i in $packages) {
    Continue
    $tmpname = $packagesLanguage.$($i[1])
    $tmppackage = $i[1]
    $tmpversion = $i[2]
    $tmpsuggest = $i[3]
    
    LogWrite "================= $tmpname ================="
    if ($tmpversion -match $gversionm) { LogWrite "Windows $gversionm can access the App $tmpname" }
    else { 
        LogWrite "Windows $gversionm cannot access the App $tmpname"
        Continue 
    }
    $fW = Get-AppxPackage $tmppackage
    if ($fW) { 

        LogWrite $Languages."delete_found"

        $choices = [System.Management.Automation.Host.ChoiceDescription[]](
            (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."yes", $Languages."delete"),
            (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."no", $Languages."keep"))
 
        $Answer = $host.ui.PromptForChoice($Languages."delete_app",$Languages."delete_app_q"+$tmpname,$choices,($tmpsuggest))

        if ($Answer -match '0') { 
            $op = Get-AppxPackage $tmppackage | Remove-AppxPackage
            if ($op) {
                LogWrite $Languages."successfully_deleted"
            } else {
                LogWrite $Languages."error_delete"
            } 
        }
        elseif ($Answer -match '1') { LogWrite $Languages."delete_skip" }
    }
    else { 

        LogWrite $Languages."didnt_found"
        
        $choices = [System.Management.Automation.Host.ChoiceDescription[]](
            (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."yes",$Languages."yes_install"),
            (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."no",$Languages."no_keep"))
 
        $Answer = $host.ui.PromptForChoice($Languages."install",$Languages."install_q"+$tmpname,$choices,(1))

        if ($Answer -match '0') { 
            $op = Get-AppxPackage -AllUsers $tmppackage | Foreach { Add-AppxPackage -DisableDevelopmentMode -Register "$
($_.InstallLocation)\AppXManifest.xml"}

            if ($op) {
                LogWrite $Languages."successfully_installed"
            } else {
                LogWrite $Languages."error_install"
            } 
        }
        elseif ($Answer -match '1') { LogWrite $Languages."install_skip" }        
    }
}

$choices = [System.Management.Automation.Host.ChoiceDescription[]](
    (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."yes_all", $Languages."yes_all_q"),
    (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."no_all", $Languages."no_all_q"))

$Answer = $host.ui.PromptForChoice($Languages."delete_all",$Languages."delete_all_q"+$s.Name,$choices,(1))

if ($Answer -match '0') {

    $allApps = Get-AppxPackage | Select Name
    Foreach ($s in $allApps) {
        Foreach ($b in $packages) {
            if ($s.Name -eq $b[1]) {
                $skip = 1
                break
            }
            else { $shouldbeeq = $s.Name }
        }
        if ($skip -eq 1) { Continue }
        else { 
            $tmpname = $s.Name
            LogWrite "================= $tmpname ================="
            $fW = Get-AppxPackage $s.Name
            if ($fW) { 

                LogWrite $Languages."delete_found"

                $choices = [System.Management.Automation.Host.ChoiceDescription[]](
                    (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."yes", $Languages."delete"),
                    (New-Object System.Management.Automation.Host.ChoiceDescription $Languages."no", $Languages."keep"))
 
                $Answer = $host.ui.PromptForChoice($Languages."delete_app",$Languages."delete_app_q"+$s.Name,$choices,(1))

                if ($Answer -match '0') { 
                    $op = Get-AppxPackage $s.Name | Remove-AppxPackage
                    if ($op) {
                        LogWrite $Languages."successfully_deleted"
                    } else {
                        LogWrite $Languages."error_delete"
                    } 
                }
                elseif ($Answer -match '1') { LogWrite $Languages."delete_skip" }
            }
        }
    }
}