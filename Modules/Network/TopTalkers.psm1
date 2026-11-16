# ============================================================
# NetPulse - Top Talkers Module
# ============================================================

$Script:PreviousTopTalkers = @{}

function Get-TrendIndicator {

    param(
        [int]$Current,
        [int]$Previous
    )

    if ($Current -gt $Previous) {
        return $Global:NetPulseSettings.TrendUp
    }

    if ($Current -lt $Previous) {
        return $Global:NetPulseSettings.TrendDown
    }

    return $Global:NetPulseSettings.TrendFlat
}

function Get-TalkerStatistics {

    $Connections = Get-NetPulseTCPConnections

    $Talkers = @()

    $Groups =
        $Connections |
        Where-Object {
            $_.RemoteAddress -and
            $_.RemoteAddress -ne "0.0.0.0" -and
            $_.RemoteAddress -ne "::"
        } |
        Group-Object RemoteAddress

    foreach ($Group in $Groups) {

        $Endpoint =
            Resolve-NetworkEndpoint -IPAddress $Group.Name

        $CurrentConnections = $Group.Count
        $PreviousConnections = 0

        if ($Script:PreviousTopTalkers.ContainsKey($Group.Name)) {
            $PreviousConnections =
                $Script:PreviousTopTalkers[$Group.Name]
        }

        $Talkers += [PSCustomObject]@{
            IPAddress           = $Group.Name
            HostName            = $Endpoint.HostName
            ServiceName         = $Endpoint.ServiceName
            Connections         = $CurrentConnections
            PreviousConnections = $PreviousConnections
            Trend               = Get-TrendIndicator `
                                    -Current $CurrentConnections `
                                    -Previous $PreviousConnections
        }
    }

    $Talkers |
    Sort-Object Connections -Descending
}

function Update-TalkerSnapshot {

    param(
        [object[]]$Talkers
    )

    $Script:PreviousTopTalkers = @{}

    foreach ($Talker in $Talkers) {

        $Script:PreviousTopTalkers[
            $Talker.IPAddress
        ] = $Talker.Connections
    }
}

function Get-TopTalkers {

    $MaxCount = $Global:NetPulseSettings.TopTalkerCount

    $Talkers = @(
        Get-TalkerStatistics |
        Select-Object -First $MaxCount
    )

    Update-TalkerSnapshot $Talkers

    $Talkers
}

function Get-TalkerDisplayName {

    param(
        [object]$Talker
    )

    $Name = $Talker.ServiceName

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = $Talker.HostName
    }

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = $Talker.IPAddress
    }

    $MaxLength =
        $Global:NetPulseSettings.MaxHostNameLength

    if ($Name.Length -gt $MaxLength) {
        $Name =
            $Name.Substring(
                0,
                $MaxLength - 3
            ) + "..."
    }

    $Name
}

function Get-TopTalkersSummary {

    $Talkers = Get-TopTalkers

    $Rows = @()

    foreach ($Talker in $Talkers) {

        $Rows += [PSCustomObject]@{
            Name        = Get-TalkerDisplayName $Talker
            Trend       = $Talker.Trend
            Connections = $Talker.Connections
            HostName    = $Talker.HostName
            IPAddress   = $Talker.IPAddress
            ServiceName = $Talker.ServiceName
        }
    }

    [PSCustomObject]@{
        TotalHosts = $Rows.Count
        Talkers    = $Rows
        Timestamp  = Get-Date
    }
}

function Clear-TopTalkersCache {

    $Script:PreviousTopTalkers = @{}
}

Export-ModuleMember -Function `
    Get-TrendIndicator, `
    Get-TalkerStatistics, `
    Get-TopTalkers, `
    Get-TalkerDisplayName, `
    Get-TopTalkersSummary, `
    Update-TalkerSnapshot, `
    Clear-TopTalkersCache