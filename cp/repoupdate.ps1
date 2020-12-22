﻿#! /bin/pwsh
cd $env:ZABBIX_CONFDIR
& git clean -f | Out-Null
& git reset --hard HEAD | Out-Null
$result = & git pull --force
if ($result.Contains("Already up to date.")) {
    Write-Host "Configuration up to date"
}
else {
    Write-Host "Configuration updated, restarting Zabbix Agent"
    # Restart Zabbix Agent in a forked process
    if ($IsLinux) {
        Start-Process -FilePath pwsh -ArgumentList '-Command "sudo systemctl restart zabbix-agent"' | Out-Null
    } else {
        Start-Process -FilePath 'powershell.exe' -ArgumentList '-Command "Restart-Service -Confirm:$false -Force \"Zabbix Agent\""' | Out-Null
    }
}