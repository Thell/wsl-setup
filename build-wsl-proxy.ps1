$Distro="wsl-proxy"
$Distro_Source_Path=$Env:HOMEPATH + "\Workspaces\WSL\Debian-Buster-10-install.tar.gz"
$Distro_Destination_Path=$Env:LOCALAPPDATA + "\WSL\wsl-proxy"
$USER=(git.exe config user.name).tolower()

Write-Host 'Distro Prep' -ForegroundColor "White" -BackgroundColor "Blue"
# This will completely remove the existing Distro and rebuild it.
# If it doesn't exist there will be errors printed but it will continue.
wsl -t $Distro
wsl --unregister $Distro
wsl --import $Distro $Distro_Destination_Path $Distro_Source_Path

# Setup the default user for the distribution and be prompted for password.
wsl -d $Distro -u root -- /bin/bash -c "/usr/sbin/adduser --gecos '' $USER"
wsl -d $Distro -u root -- /bin/bash -c "/usr/sbin/usermod -aG adm,cdrom,sudo,dip,plugdev $USER"
Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName |
  Where-Object -Property DistributionName -eq $Distro |
  Set-ItemProperty -Name DefaultUid -Value 1000

# Build the proxy server...
$sw = New-Object System.Diagnostics.Stopwatch
$sw.Start()

Write-Host 'proxy-repositories' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/wsl-proxy-repositories.sh

write-host "Starting Nexus Repository ..."
wsl -d $Distro -u $USER -- sudo systemctl start nexus
Start-Sleep 2
wsl -d $Distro -u $USER -- nexus-start-monitor

Write-Host 'wsl-nexus-stores' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/nexus-repositories/focal-cran40-apt-proxy.sh
wsl -d $Distro -u root -- ./scripts/nexus-repositories/focal-rspm40-r-proxy.sh
wsl -d $Distro -u root -- ./scripts/nexus-repositories/github-proxy.sh
wsl -d $Distro -u root -- ./scripts/nexus-repositories/api-github-proxy.sh
wsl -d $Distro -u root -- ./scripts/nexus-repositories/raw-githubusercontent-proxy.sh
wsl -d $Distro -u root -- ./scripts/nexus-repositories/s3-amazonaws-proxy.sh
wsl -d $Distro -u root -- ./scripts/nexus-repositories/texlive-proxy.sh
wsl -d $Distro -u root -- ./scripts/nexus-repositories/tinytex-proxy.sh

Write-Host 'Complete: ' + $sw.Elapsed.Duration().ToString() -ForegroundColor "White" -BackgroundColor "Blue"
Write-Host "Logon to Nexus Repository to set admin password."