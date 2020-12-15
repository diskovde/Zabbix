﻿param([string]$VMName='')

$xmlpath = $($env:ZABBIX_CONFDIR + "\state\VBRdump.xml")

Add-PSSnapin VeeamPSSnapIn

class jobinfo
{
    [string]$jobname
    [string]$jobstatus
    [uint64]$lastrun
	# [Veeam.Backup.Core.CBackupTaskSession]$veeamtasksession
    jobinfo([DateTime]$lastrun, $veeamtasksession) {
        $this.jobname = ($veeamtasksession.JobName + "_" + $veeamtasksession.Name).ToLower().Replace(" ", "_").Replace("å","a").Replace("ä","a").Replace("ö","o");
        $this.jobstatus = $veeamtasksession.Status
        $this.lastrun = (($lastrun | Get-Date -UFormat %s), 0 | Measure-Object -Max).Maximum
    }
}

$data = [array]@()

# Get information about one job
if (-Not [string]::IsNullOrWhiteSpace($VMName)) {
    # Load cached veeam data from discovery
    $veeamdata = Import-Clixml -Path $xmlpath
    if (($veeamdata | Where-Object { $_.jobname -eq $VMName } | Measure-Object).Count -le 0) {
        exit
    }
    $veeamdata | Where-Object { $_.jobname -eq $VMName } | Select-Object -First 1 | ConvertTo-Json -Compress
    exit
}

Get-VBRJob | ForEach-Object {
    [Veeam.Backup.Core.CBackupSession]$session = $_.FindLastSession()
    [DateTime]$lastrun = $_.LatestRunLocal.ToUniversalTime()

    if (-Not $session) { continue }

    $session.GetTaskSessions() | ForEach-Object {
        [jobinfo]$jobinfo = New-Object jobinfo -ArgumentList $lastrun,$_
        $data += $jobinfo
    }
}

# Store data as "CLIXML" for querying faster later.
$data | Export-Clixml -Path $xmlpath -Encoding UTF8
# Output discovery data to screen in JSON format (Zabbix reads this)
$json = $data | ConvertTo-Json -Compress
$json