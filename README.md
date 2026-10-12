# powershell-headless

PowerShell scripts for headless command-line execution. This repository is public; its raw script URLs can be downloaded anonymously.

## Scripts

- `hello-world.ps1`: prints `hello world` in the terminal.
- `Run-GitHubScript.ps1`: downloads a script from a raw GitHub HTTPS URL, runs it in a separate PowerShell process, returns its exit code, and removes the temporary file. Download failures return exit code 1.

## One command from Windows Command Prompt (cmd.exe)

This downloads and runs the hello-world script after `ipconfig /flushdns`, without needing a launcher file installed first:

```cmd
ipconfig /flushdns & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $p=Join-Path $env:TEMP ([guid]::NewGuid().ToString()+'.ps1'); try { Invoke-WebRequest 'https://raw.githubusercontent.com/iso-work/powershell-headless/main/hello-world.ps1' -UseBasicParsing -OutFile $p -TimeoutSec 60; & $p } finally { Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue }"
```

These quotes and the command separator are for Command Prompt, not a PowerShell prompt.

| CMD separator | Behavior |
| --- | --- |
| `&` | Run the next command regardless of the previous command's result |
| `&&` | Run it only if the previous command succeeds |
| `\|\|` | Run it only if the previous command fails |
| `\|` | Pipe output into the next command |

## Reusable downloader

Save `Run-GitHubScript.ps1` locally, then run it from Command Prompt:

```cmd
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ".\Run-GitHubScript.ps1" -Url "https://raw.githubusercontent.com/iso-work/powershell-headless/main/hello-world.ps1"
```

The example follows `main`, so later edits to the script will be picked up automatically. Replace `main` in the URL with a commit SHA to run a fixed version.

`ExecutionPolicy Bypass` applies to the launched processes; it does not change the machine's saved execution policy.
