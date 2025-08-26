# Before running ensure that PowerShell 7 is installed
# https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5
# winget install --id Microsoft.PowerShell --source winget 

# -----------------------------------------------------------------------
# OpenSSH Setup
#
# REQUIRED - Configure OpenSSH for Windows
# -----------------------------------------------------------------------
Write-Host "🔄 Setting up OpenSSH..."

Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Write-Host "🔄 Starting and configuring sshd service..."

if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
    # Set startup type to Automatic if not already set
    $service = Get-Service -Name sshd

    # Start service only if not already running
    if ($service.Status -ne "Running") {
        Start-Service sshd
        Write-Output "✅ sshd started."
    }
    else
    {
        Write-Output "ℹ️ sshd already running."
    }

    $startupType = (Get-WmiObject -Class Win32_Service -Filter "Name='sshd'").StartMode
    if ($startupType -ne "Auto") {
        Set-Service -Name sshd -StartupType 'Automatic'
        Write-Output "✅ sshd auto start configured."
    }
    else 
    {
        Write-Output "ℹ️ sshd service auto start already configured."
    }


} else {
    Write-Host "❌ sshd service not found."
}



# Confirm the Firewall rule is configured.
Write-Host "🔄 Checking firewall rules..."

if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Host "🔄 Creating firewall rule 'OpenSSH-Server-In-TCP'..."
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

    Write-Output "✅ Firewall rules configured."
} else {
    Write-Output "ℹ️ Firewall rule 'OpenSSH-Server-In-TCP' already exists. No change needed."
}

# -----------------------------------------------------------------------
# OpenSSH Configuration
#
# ✅ Set default SSH shell to PowerShell 7
# ✅ Configure SSH authorized key files.
# -----------------------------------------------------------------------

$regPath  = 'HKLM:\SOFTWARE\OpenSSH'
$regName  = 'DefaultShell'
$newValue = 'C:\Program Files\PowerShell\7\pwsh.exe'

Write-Host "🔄 Configuring default SSH shell..."

# Ensure the registry path exists
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Check current value
$currentValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName

if ($currentValue -ne $newValue) {
    Set-ItemProperty -Path $regPath -Name $regName -Value $newValue
    Write-Output "✅ Default SSH Shell set to PowerShell 7."
} else {
    Write-Output "ℹ️ Default SSH Shell is already set to PowerShell 7. No change needed."
}

# create administrators_authorized_keys if not exists
Write-Host "🔄 Configuring SSH key files..."

$sshDir = "$env:ProgramData\ssh"
$authKeysFile = Join-Path $sshDir "administrators_authorized_keys"

if (-not (Test-Path $authKeysFile)) {
    Write-Host "🔄 Creating administrators_authorized_keys file..."
    New-Item -ItemType File -Path $authKeysFile -Force | Out-Null

    Write-Host "🔄 Setting correct permissions..."
    icacls $authKeysFile /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F" | Out-Null

    Write-Output "✅ SSH authorized key files ready."
} else {
    Write-Host "ℹ️ administrators_authorized_keys already exists."
}

# -----------------------------------------------------------------------
# WSL2 Setup
# 
# OPTIONAL - Ensure that WSL2 is ready if we need a control node
# -----------------------------------------------------------------------

$wslInput = Read-Host "`n🐧 Setup WSL2? (Yes/No)"
if ($wslInput.Trim().ToLower() -eq 'yes' -or $wslInput.Trim().ToLower() -eq 'y') {
    Write-Output "🚀 Setting up WSL2..."

    wsl --install

    Write-Output "✅ WSL2 installed."
    Write-Output "👉 Launch Ubuntu from Start Menu or run 'wsl' to complete first-time setup (create user/password)."

} else {
    Write-Output "ℹ️ WSL installation skipped."
}