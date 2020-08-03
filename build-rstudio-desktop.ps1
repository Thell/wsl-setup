$Distro="wsl-rstudio"
$Distro_Source_Path=$Env:HOMEPATH + "\Workspaces\WSL\User-Ubuntu-Focal-2004-install.tar.gz"
$Distro_Destination_Path=$Env:LOCALAPPDATA + "\WSL\$Distro"
$USER=(git.exe config user.name).tolower()

Write-Host 'Distro Prep' -ForegroundColor "White" -BackgroundColor "Blue"
# This will completely remove the existing Distro and rebuild it.
# If it doesn't exist there will be errors printed but it will continue.
wsl -t $Distro
wsl --unregister $Distro
wsl --import $Distro $Distro_Destination_Path $Distro_Source_Path

# Setup the default user for the distribution and be prompted for password.
Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName |
  Where-Object -Property DistributionName -eq $Distro |
  Set-ItemProperty -Name DefaultUid -Value 1000

# Build the proxy server...
$sw = New-Object System.Diagnostics.Stopwatch
$sw.Start()

Write-Host 'RStudio-Support-Apps' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/wsl-rstudio-support-apps.sh

Write-Host 'RStudio-System' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/wsl-rstudio-system.sh

Write-Host 'RStudio-User' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u $USER -- /bin/bash --login -c ". ./scripts/wsl-rstudio-user.sh"

Write-Host 'Complete: ' + $sw.Elapsed.Duration().ToString() -ForegroundColor "White" -BackgroundColor "Blue"
