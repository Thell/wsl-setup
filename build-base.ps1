$Distro="Ubuntu"

cls;
wsl -t $Distro
wsl --unregister $Distro
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

Write-Host 'Complete: ' + $sw.Elapsed.Duration().ToString() -ForegroundColor "White" -BackgroundColor "Blue"
