$Distro="Ubuntu"
$DO_EXPORT=$true
$Export_Destination_Path=$Env:HOMEPATH + "\Workspaces\WSL\User-Ubuntu-Focal-2004-install.tar.gz"
$USER=(git.exe config user.name).tolower()

# This will completely remove the existing Distro and rebuild it.
# If it doesn't exist there will be errors printed but it will continue.
Clear-Host;
wsl -t $Distro
wsl --unregister $Distro

# After entering the user name and password exiting will continue the script.
& $Distro

$sw = New-Object System.Diagnostics.Stopwatch
$sw.Start()

Write-Host 'Gobal Apt' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/00-global-apt.sh

Write-Host 'Global Profile' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/01-global-profile.sh

Write-Host 'Global Bashrc' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/02-global-bashrc.sh

Write-Host 'Global GUI' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u root -- ./scripts/03-global-gui.sh

Write-Host 'User Profile' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u $USER -- ./scripts/10-user-profile.sh

Write-Host 'User Bash' -ForegroundColor "White" -BackgroundColor "Blue"
wsl -d $Distro -u $USER -- ./scripts/11-user-bash.sh

if ($DO_EXPORT) {
  Write-Host 'Exporting' -ForegroundColor "White" -BackgroundColor "Blue"
  wsl --export $Distro $Export_Destination_Path
}

Write-Host 'Complete: ' + $sw.Elapsed.Duration().ToString() -ForegroundColor "White" -BackgroundColor "Blue"
