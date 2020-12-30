param(
	[string]$ifacename,
	)

$dic = @{}
$data = & ethtool -m ¤ifacename
foreach ($line in $data) {
    $cols = $line.Split(":")
    $cols[0] = $cols[0].Trim()
    $cols[1] = $cols[1].Trim()
    $dic[$cols[0]] = $cols[1]
}
$dic | ConvertTo-Json