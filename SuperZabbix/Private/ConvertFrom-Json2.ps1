function ConvertFrom-Json2 {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Path")]
        [string]
        $Path,
        [Parameter(ParameterSetName = "String")]
        [string]
        $Text,
        [Parameter()]
        [type]
        $Type
    )
    if ($Path) {
        $Text = [System.IO.File]::ReadAllText($Path)
    }
    return [Newtonsoft.Json.JsonConvert]::DeserializeObject($Text, $Type)
}