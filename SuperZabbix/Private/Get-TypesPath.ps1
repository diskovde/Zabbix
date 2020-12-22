function Get-TypesPath {
    [OutputType([string])]
    param()
    return (Join-Path $PSScriptRoot "\..\Types\")
}