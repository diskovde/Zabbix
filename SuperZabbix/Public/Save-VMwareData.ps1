Import-Module (Join-Path (Get-TypesPath) "VMwareTypes.ps1") -Force

function Save-VMwareData {
    param(
        [string]$Hostname,
        [string]$Username,
        [string]$Password
    )

    try { # We're probably not connected to a vCenter, but in case we are we disconnect from it first
        Disconnect-VIServer -Force -Confirm:$false -ErrorAction Ignore | Out-Null
    } catch {}
    Connect-VIServer -Server $Hostname -User $Username -Password $Password -Force | Out-Null
    
    [VMwareRoot]$vmwareroot = New-Object VMwareRoot
    $vmwareroot.lastupdate = (Get-Date -AsUTC -UFormat %s -Millisecond 0) # unixtime
    
    foreach ($vmhost in Get-VMHost) {
        [VMHostInfo]$hostinfo = New-Object VMHostInfo
        $hostinfo.name = $vmhost.Name
        $cli = Get-EsxCli -VMHost $vmhost -V2

        # Get vSAN stats
        foreach ($diskgroup in (Get-VsanDiskGroup -VMHost $vmhost)) {
            [VMHostDiskGroup]$group = [VMHostDiskGroup]::new()
            $group.Id = $diskgroup.Uuid

            foreach ($stat in Get-VsanStat -Entity $diskgroup -StartTime (Get-Date).AddMinutes(-5) -EndTime (Get-Date) | Sort-Object -Property Time) {
                $group.stats[$stat.Name.Replace("Performance.","")] = $stat.Value
            }
            $hostinfo.vsanstats.Add($group)
        }
    
        foreach ($device in $cli.storage.core.device.list.Invoke()) {
            $sargs = $cli.storage.core.device.smart.get.CreateArgs()
            $sargs.devicename = $device.Device
            $smart = $null
            try {
                $smart = $cli.storage.core.device.smart.get.Invoke($sargs)
            }
            catch { break; } # SMART isn't supported on $device.
        
            [VMDriveInfo]$hostdrive = New-Object VMDriveInfo
            $hostdrive.deviceName = $device.DisplayName
            $hostdrive.deviceModel = $device.Model
            $hostdrive.device = $device.Device
            while ($hostdrive.device.Contains("__")) {
                $hostdrive.device = $hostdrive.device.Replace("__", "_")
            }
            foreach ($parameter in $smart) {
                $smartdata = [VMSmartInfo](New-Object -TypeName VMSmartInfo -ArgumentList $parameter)
                $key = $smartdata.name.Replace(" ","")
                $hostdrive.smartParams.Add($key, $smartdata)
            }
            $hostinfo.drives.Add($hostdrive)
        }
    
        $vmwareroot.vmhosts.Add($hostinfo)
    }

    $vmwareroot | ConvertTo-Json2 | Out-File -FilePath (Join-Path -Path (Get-TempPath) "vmwaredata.json")
    $vmwareroot = ConvertFrom-Json2 -Path (Join-Path -Path (Get-TempPath) "vmwaredata.json") -Type $vmwareroot.GetType()
    
    Disconnect-VIServer -Confirm:$false
    Write-Host "Success"
}

Export-ModuleMember -Function Save-VMwareData