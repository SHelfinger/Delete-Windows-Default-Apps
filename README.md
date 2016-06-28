# Delete-Windows-Default-Apps
## .SYNOPSIS
Delete-Apps.ps1 - PowerShell script to detect Windows Apps and delete/installs it.

## .DESCRIPTION 
This PowerShell script will try to get the AppxPackage and delete or install the application 
on your Windows 8, Windows 8.1 or Windows 10 device. You will need to execute on some devices 
the following PowerShell command: 
```Powershell
"Set-ExecutionPolicy RemoteSigned"
```
this will ensure you 
have enough privileges to delete those apps. Also you have the ability to delete system Apps,
where we don't have in our Database.ps1 - Support us and send us your list of Apps: 
"Get-AppxPackage | Select Name" in PowerShell and send us the output or you can directly save 
in a text file with the following command: 
```Powershell
"Get-AppxPackage | Select Name >> $env:userprofile\Desktop\Windows-Apps_$(gc env:computername).txt"
```

## .EXAMPLE
```Powershell
.\Delete-Apps.ps1
```

## .OUTPUT
NONE

## .PARAMETER LANG CODE (2 Letter ISO Code)
You can also switch the language by .\Delete-Apps.ps1 DE (for German)

Currently supported languages DE,FR,EN

## .NOTES
Written by Sascha Sebastian Helfinger - sascha.sebastian.helfinger@shelfinger.com, sh@shelfinger.eu

Technical Consultant/Director at SHelfinger Sarl - https://shelfinger.eu, http://shelfinger.com

You can also find me on:

* Twitter: https://twitter.com/shelfinger
* LinkedIn: http://tg.linkedin.com/in/shelfinger/
* Github: https://github.com/shelfinger
* Facebook: https://facebook.com/SHelfinger.EU

## License:

[The MIT License (MIT)](../blob/master/LICENSE)

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

## Change Log:
```
V1.00, 31/05/2016 - First release
V1.01, 02/06/2016 - Database updatable function included
V1.02, 03/06/2016 - Language (DE, FR, EN) and updatable function included
V1.03, 04/06/2016 - Added the Global Package delete function
V1.04, 27/06/2016 - Bug from "Updating the Database" when it's older than 7 days
```
