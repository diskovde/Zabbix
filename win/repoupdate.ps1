cd $env:ZABBIX_CONFDIR
& git clean -f
& git reset --hard HEAD
$result = & git pull --force
if ($result.Contains("Already up to date.")) {
	Write-Host "Configuration up to date"
}
else {
	Write-Host "Configuration updated, restarting Zabbix Agent"
	Restart-Service "Zabbix Agent"
}