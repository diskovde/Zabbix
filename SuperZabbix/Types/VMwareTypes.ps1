class VMSmartInfo {
    [string]$name
    [int64]$raw
    [int]$threshhold
    [string]$value
    [int]$worst

    VMSmartInfo($parampack) {
        $this.name = $parampack.Parameter -ne "N/A" ? $parampack.Parameter : "Invalid Name"
        $this.raw = $parampack.Raw -ne "N/A" ? $parampack.Raw : 0
        $this.threshhold = $parampack.Threshold -ne "N/A" ? $parampack.Threshold : 0
        $this.value = $parampack.Value -ne "N/A" ? $parampack.Value : 100
        $this.worst = $parampack.Worst -ne "N/A" ? $parampack.Worst : 100
    }
    [string] ToString() {
        return $this.value
    }
}

class VMDriveInfo {
    [string]$deviceName
    [string]$deviceModel
    [string]$device
    [System.Collections.Generic.Dictionary[[string],[VMSmartInfo]]]$smartParams

    VMDriveInfo() {
        $this.smartParams = [System.Collections.Generic.Dictionary[[string],[VMSmartInfo]]]::new()
    }
}

class VMHostDiskGroup {
    [string]$Id
    [System.Collections.Generic.Dictionary[[string],[int64]]]$stats
    VMHostDiskGroup() {
        $this.stats = [System.Collections.Generic.Dictionary[[string],[int64]]]::new()
    }
}

class VMHostInfo {
    [string]$name
    [System.Collections.Generic.List[VMDriveInfo]]$drives
    [System.Collections.Generic.List[VMHostDiskGroup]]$vsanstats

    VMHostInfo() {
        $this.drives = [System.Collections.Generic.List[VMDriveInfo]]::new()
        $this.vsanstats = [System.Collections.Generic.List[VMHostDiskGroup]]::new()
    }
}

class VMwareRoot {
    [uint64]$lastupdate
    [System.Collections.Generic.List[VMHostInfo]]$vmhosts
    VMwareRoot() {
        $this.vmhosts = [System.Collections.Generic.List[VMHostInfo]]::new()
    }
}
