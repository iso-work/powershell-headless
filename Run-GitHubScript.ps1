<#
.SYNOPSIS
Downloads a public GitHub PowerShell script and runs it in the terminal.
.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Run-GitHubScript.ps1 -Url "https://raw.githubusercontent.com/OWNER/REPOSITORY/main/hello-world.ps1"
.NOTES
Use the script's raw URL, not its GitHub file-view page. This version is for
public repositories; private repositories require authentication.
ExecutionPolicy Bypass applies only to the launched processes.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ $_.IsAbsoluteUri -and $_.Scheme -eq 'https' -and $_.Host -eq 'raw.githubusercontent.com' })]
    [uri]$Url
)

$ErrorActionPreference = 'Stop'
$downloadPath = Join-Path ([IO.Path]::GetTempPath()) ('github-' + [guid]::NewGuid().ToString('N') + '.ps1')
$scriptExitCode = 1

try {
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    }

    Invoke-WebRequest -Uri $Url -UseBasicParsing -OutFile $downloadPath -TimeoutSec 60 -ErrorAction Stop
    $powerShellExecutable = (Get-Process -Id $PID).Path
    & $powerShellExecutable -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $downloadPath
    $scriptExitCode = $LASTEXITCODE
}
catch {
    [Console]::Error.WriteLine('Download or execution failed: ' + $_.Exception.Message)
}
finally {
    Remove-Item -LiteralPath $downloadPath -Force -ErrorAction SilentlyContinue
}

exit $scriptExitCode
