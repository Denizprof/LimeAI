# Lime — one-command setup for Windows.
# Installs Ollama (if missing), pulls the qwen2.5:14b local AI model, then
# downloads and launches the Lime installer.
#
# Run in PowerShell:
#   irm https://raw.githubusercontent.com/Denizprof/LimeAI/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

Write-Host "Lime setup" -ForegroundColor Green
Write-Host "This will install Ollama (if needed), pull the qwen2.5:14b model (~9GB), and launch the Lime installer.`n"

# 1) Ollama ---------------------------------------------------------------
Write-Step "Checking for Ollama..."
$ollamaInstalled = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaInstalled) {
  Write-Host "Ollama not found — installing via winget..."
  try {
    winget install --id Ollama.Ollama -e --accept-source-agreements --accept-package-agreements
  } catch {
    Write-Host "winget install failed — falling back to the official installer." -ForegroundColor Yellow
    $ollamaSetup = Join-Path $env:TEMP 'OllamaSetup.exe'
    Invoke-WebRequest -Uri 'https://ollama.com/download/OllamaSetup.exe' -OutFile $ollamaSetup
    Start-Process -FilePath $ollamaSetup -Wait
  }
  # winget/installer usually adds ollama to PATH but the current shell
  # session won't see it until PATH is refreshed
  $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
} else {
  Write-Host "Ollama already installed."
}

# 2) Model ------------------------------------------------------------------
Write-Step "Pulling the qwen2.5:14b model (this is a real ~9GB download, it will take a while)..."
try {
  ollama pull qwen2.5:14b
} catch {
  Write-Host "Could not pull the model automatically. Once Ollama is running, pull it yourself with:" -ForegroundColor Yellow
  Write-Host "    ollama pull qwen2.5:14b"
}

# 3) Lime itself --------------------------------------------------------------
Write-Step "Downloading Lime..."
$limeSetup = Join-Path $env:TEMP 'Lime-Setup-1.0.0.exe'
Invoke-WebRequest -Uri 'https://github.com/Denizprof/LimeAI/releases/download/v1.0.0/Lime-Setup-1.0.0.exe' -OutFile $limeSetup

Write-Step "Launching the Lime installer..."
Start-Process -FilePath $limeSetup

Write-Host "`nDone. Follow the installer window to finish setting up Lime." -ForegroundColor Green
