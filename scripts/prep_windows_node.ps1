# RUN AS ADMIN 
#Before running ensure that PowerShell 7 is installed
# https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5
# winget install --id Microsoft.PowerShell --source winget 

# --- OpenSSH Setup ---
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the SSH service and start automatically in the future
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

Write-Output "✅ OpenSSH Server installed and started"

# Confirm the Firewall rule is configured.
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}

Write-Output "✅ Firewall rules configured."

# Set default to powershell.exe
$shellParams = @{
    Path         = 'HKLM:\SOFTWARE\OpenSSH'
    Name         = 'DefaultShell'
    Value        = 'C:\Program Files\PowerShell\7\pwsh.exe'
    PropertyType = 'String'
    Force        = $true
}
New-ItemProperty @shellParams

Write-Output "✅ Default SSH Shell set to PowerShell 7."

# --- Interactive WSL2 Setup ---
$wslInput = Read-Host "`n🐧 Setup control node in WSL2? (Yes/No)"
if ($wslInput.Trim().ToLower() -eq 'yes' -or $wslInput.Trim().ToLower() -eq 'y') {
    Write-Output "🚀 Setting up WSL2..."

    wsl --install

    Write-Output "✅ WSL2 installed."
    Write-Output "👉 Launch Ubuntu from Start Menu or run 'wsl' to complete first-time setup (create user/password)."
    
    wsl -e ./prep_wsl2_control_node.sh

} else {
    Write-Output "ℹ️ WSL installation skipped."
}