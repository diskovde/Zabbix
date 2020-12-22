function Get-VMwareData {
    [OutputType([VMwareRoot])]
    param()

    return ConvertFrom-Json2 -Path (Join-Path (Get-TempPath) "vmwaredata.json") -Type ([VMwareRoot]::new()).GetType()
}
