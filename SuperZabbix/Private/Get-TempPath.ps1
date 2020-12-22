function Get-TempPath {
    if ($IsWindows) {
        return $env:TEMP
    } elseif ($IsLinux) {
        return "/tmp/"
    }
    throw [Exception] "Get-TempPath is only supported on Windows and Linux"
}