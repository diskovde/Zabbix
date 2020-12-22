Import-Module (Join-Path (Get-TypesPath) "VMwareTypes.ps1") -Force

function Get-vSANParameters {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $VMHost,
        [Parameter()]
        [string]
        $DGId
    )

    [VMwareRoot]$data = Get-VMwareData
    $stats = $data.vmhosts | Where-Object { $_.name -eq $VMHost }

    if ([string]::IsNullOrWhiteSpace($DGId)) {
        ,$stats.vsanstats | ConvertTo-Json2 # The "," prefix is required to stop PowerShell from unboxing arrays with one item in them
    }
    else {
        (,$stats.vsanstats | Where-Object { $_.Id -eq $DGId }) | ConvertTo-Json2 
    }
}
