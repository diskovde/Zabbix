param([string]$JobName='')

$xmlpath = $($env:ZABBIX_CONFDIR + "\state\veeamdump.xml")

Add-PSSnapin VeeamPSSnapIn

function CCToJobInfo {
    param (
        $veeamjob
    )
    $jobinfo = New-Object jobinfo
    $jobinfo.jobname = $veeamjob.Name
    $jobinfo.jobstatus = $veeamjob.Lastresult
    try
    {
        $jobinfo.lastrun = [datetime]::ParseExact($veeamjob.Lastactive, "dd.MM.yyyy hh:mm", $null).ToUnixTimeSeconds()
    }
    catch 
    {
        $jobinfo.lastrun = [DateTimeOffset]::Now.ToUnixTimeSeconds()
    }
    return $jobinfo
}

class jobinfo
{
    [string]$jobname
    [string]$jobstatus
    [uint64]$lastrun
}

# Get information about one job
if (-Not [string]::IsNullOrWhiteSpace($JobName)) {
    # Load cached veeam data from discovery
    $veeamdata = Import-Clixml -Path $xmlpath
    if (($veeamdata | Where-Object { $_.jobname -eq $JobName } | Measure-Object).Count -le 0) {
        exit
    }
    $veeamdata | Where-Object { $_.jobname -eq $JobName } | Select-Object -First 1 | ConvertTo-Json -Compress
    exit
}

# Discovery all jobs
$data = [array]@()


Get-VBRCloudTenant | Where-Object { $_.Enabled -eq "True" } | ForEach-Object {
    $jobinfo = CCToJobInfo -veeamjob $_
    $data += $jobinfo
}

# Store data as "CLIXML" for querying faster later.
$data | Export-Clixml -Path $xmlpath -Encoding UTF8
# Output discovery data to screen in JSON format (Zabbix reads this)
$json = $data | ConvertTo-Json -Compress
$json