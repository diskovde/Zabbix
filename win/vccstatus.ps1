param([string]$TenantName='')

$xmlpath = $($env:ZABBIX_CONFDIR + "\state\VCCdump.xml")

Add-PSSnapin VeeamPSSnapIn

class jobinfo
{
    [string]$jobname
    [string]$jobstatus
    [uint64]$lastrun

    jobinfo($vccjob) {
        $this.jobname = $vccjob.Name.Replace(" ", "_");
        $this.jobstatus = $vccjob.Lastresult
        try
        {
            $this.lastrun = [datetime]::ParseExact($vccjob.LastActive, "dd.MM.yyyy HH:mm", $null).ToUniversalTime() | Get-Date -UFormat "%s"
        }
        catch 
        {
            $this.lastrun = [DateTimeOffset]::Now.ToUnixTimeSeconds()
        }
    }
}

# Get information about one job
if (-Not [string]::IsNullOrWhiteSpace($TenantName)) {
    # Load cached veeam data from discovery
    $veeamdata = Import-Clixml -Path $xmlpath
    if (($veeamdata | Where-Object { $_.jobname -eq $TenantName } | Measure-Object).Count -le 0) {
        exit
    }
    $veeamdata | Where-Object { $_.jobname -eq $TenantName } | Select-Object -First 1 | ConvertTo-Json -Compress
    exit
}

# Discover all jobs
$data = [array]@()


Get-VBRCloudTenant | Where-Object { $_.Enabled -eq "True" -and $_.GetType().Name -eq "VBRCloudTenant" } | ForEach-Object {
    $jobinfo = New-Object jobinfo -ArgumentList $_
    $data += $jobinfo
}

# Store data as "CLIXML" for querying faster later.
$data | Export-Clixml -Path $xmlpath -Encoding UTF8
# Output discovery data to screen in JSON format (Zabbix reads this)
$json = $data | ConvertTo-Json -Compress
$json