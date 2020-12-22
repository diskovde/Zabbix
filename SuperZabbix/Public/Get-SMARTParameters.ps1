Import-Module (Join-Path (Get-TypesPath) "VMwareTypes.ps1") -Force

function Get-SMARTParameters{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $VMHost,
        [Parameter()]
        [string]
        $Device
    )

    [VMwareRoot]$data = Get-VMwareData
    $stats = $data.vmhosts | Where-Object { $_.name -eq $VMHost }

    if ([string]::IsNullOrWhiteSpace($Device)) {
        ,$stats.drives | ConvertTo-Json2 # The "," prefix is required to stop PowerShell from unboxing arrays with one item in them
    }
    else {
        (,$stats.drives | Where-Object { $_.Device -eq $Device }) | ConvertTo-Json2 
    }
}
