$sw = New-Object System.Diagnostics.Stopwatch
$sw.Start()

Write-Host 'Global Profile' -ForegroundColor "White" -BackgroundColor "Blue"

wsl -d Ubuntu -u root -- ./scripts/00-global-profile.sh

Write-Host 'Global Bashrc' -ForegroundColor "White" -BackgroundColor "Blue"

wsl -d Ubuntu -u root -- ./scripts/01-global-bashrc.sh

Write-Host 'Apt Proxy and Updates' -ForegroundColor "White" -BackgroundColor "Blue"

wsl -d Ubuntu -u root -- ./scripts/02-global-apt.sh

Write-Host 'Complete: ' + $sw.Elapsed.Duration().ToString() -ForegroundColor "White" -BackgroundColor "Blue"
