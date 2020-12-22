function ConvertTo-Json2 {
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true)]
        [object]
        $InputObject,
        [Parameter()]
        [bool]
        $Compress
    )
    return [Newtonsoft.Json.JsonConvert]::SerializeObject($InputObject, $compress ? [Newtonsoft.Json.Formatting]::None : [Newtonsoft.Json.Formatting]::Indented)
}