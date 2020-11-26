cd $env:ZABBIX_CONFDIR
& git clean -f | Out-Null
& git reset --hard HEAD | Out-Null
$result = & git pull --force
if ($result.Contains("Already up to date.")) {
	Write-Host "Configuration up to date"
}
else {
	Write-Host "Configuration updated, restarting Zabbix Agent"
	Restart-Service "Zabbix Agent"
}