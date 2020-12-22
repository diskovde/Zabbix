param(
	[string]$URL,
	[string]$Username,
	[string]$Password,
	[bool]$Fork
	)
Import-Module (Join-Path $env:ZABBIX_CONFDIR "SuperZabbix") -Force

# Base64 decoding, macros with "weird" characters in it are not appreciated by userparams
$URL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($URL))
$Hostname = ([System.Uri]$URL).Host # Convert URL to [System.Uri] and extract host
$Username = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Username))
$Password = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Password))

if ($Fork) {
    & pwsh -File "%ZABBIX_CONFDIR%\win\VMware_SaveData.ps1" -URL "$1" -Username "$2" -Password "$3" -Fork:$false
}
else {
    Save-VMwareData -Hostname $Hostname -Username $Username -Password $Password
}