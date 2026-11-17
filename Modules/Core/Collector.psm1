# ============================================================
# NetPulse - Collector Module
# ============================================================

function Get-NetPulseEvents {

    param(
        [object]$Traffic,
        [object]$Connections
    )

    $Events = @()

    if ($Traffic.Current.InboundMBps -gt $Global:NetPulseSettings.HighTrafficMBps) {

        $Events += [PSCustomObject]@{
            Time    = Get-Date
            Message = "High inbound traffic detected"
        }
    }

    if ($Traffic.Current.OutboundMBps -gt $Global:NetPulseSettings.HighTrafficMBps) {

        $Events += [PSCustomObject]@{
            Time    = Get-Date
            Message = "High outbound traffic detected"
        }
    }

    if ($Connections.Statistics.Established -gt $Global:NetPulseSettings.HighConnectionCount) {

        $Events += [PSCustomObject]@{
            Time    = Get-Date
            Message = "High connection count detected"
        }
    }

    if ($Events.Count -eq 0) {

        $Events += [PSCustomObject]@{
            Time    = Get-Date
            Message = "Monitoring"
        }
    }

    $EventLimit = $Global:NetPulseSettings.EventLogSize

    return @(
        $Events |
        Sort-Object Time -Descending |
        Select-Object -First $EventLimit
    )
}

function Get-NetPulseStatus {

    param(
        [object]$Traffic,
        [object]$Connections
    )

    if (-not $Traffic -or -not $Connections) {
        return "UNKNOWN"
    }

    if (
        $Traffic.Current.InboundMBps -gt $Global:NetPulseSettings.HighTrafficMBps -or
        $Traffic.Current.OutboundMBps -gt $Global:NetPulseSettings.HighTrafficMBps
    ) {
        return "WARNING"
    }

    if (
        $Connections.Statistics.Established -gt
        $Global:NetPulseSettings.HighConnectionCount
    ) {
        return "WARNING"
    }

    return "HEALTHY"
}

function Get-NetPulseData {

    #
    # Collect once
    #

    $Traffic      = Get-TrafficSummary
    $Connections  = Get-ConnectionsSnapshot
    $Protocols    = Get-ProtocolSummary
    $TopTalkers   = Get-TopTalkersSummary
    $ResolverInfo = Get-ResolverStatistics

    #
    # Reuse everywhere
    #

    $Events = Get-NetPulseEvents `
        -Traffic $Traffic `
        -Connections $Connections

    $Status = Get-NetPulseStatus `
        -Traffic $Traffic `
        -Connections $Connections

    [PSCustomObject]@{

        Timestamp   = Get-Date

        Status      = $Status

        Traffic     = $Traffic
        Connections = $Connections
        Protocols   = $Protocols
        TopTalkers  = $TopTalkers
        Resolver    = $ResolverInfo
        Events      = $Events
    }
}

function Initialize-Collector {

    Initialize-History @(
        "Inbound"
        "Outbound"
        "Packets"
        "Connections"
    )

    Initialize-Resolver
}

function Reset-Collector {

    Clear-History

    Clear-ResolverCache

    Clear-TopTalkersCache

    Reset-TrafficModule
}

Export-ModuleMember -Function `
    Initialize-Collector, `
    Get-NetPulseData, `
    Get-NetPulseStatus, `
    Get-NetPulseEvents, `
    Reset-Collector