$($smallestpct = 1.0; foreach ($i in Get-Volume | Where-Object { $_.DriveType -eq "Fixed" }) {
  $smallestpct = [math]::min($smallestpct, $i.SizeRemaining / $i.Size)
}
Write-Host ($smallestpct * 100))
