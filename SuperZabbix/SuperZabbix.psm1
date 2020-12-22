#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Types =   @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Import everything twice to make sure everything within the module can call itself
$Imports = @($Types + $Private + $Public)
foreach ($import in @($Imports + $Imports))
{
    try
    {
        Import-Module $import.fullname -Force
    }
    catch
    {
        Write-Error -Message "Failed to import file/function $($import.fullname): $_"
    }
}

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false | Out-Null

Export-ModuleMember -Function $Public.Basename