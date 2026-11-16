# ============================================================
# NetPulse - Collector Module
# ============================================================

function Get-NetPulseEvents {

    $Events = @()

    try {

        $Traffic = Get-TrafficSummary

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
    }
    catch {
    }

    try {

        $Connections = Get-ConnectionsSnapshot

        if ($Connections.Statistics.Established -gt $Global:NetPulseSettings.HighConnectionCount) {

            $Events += [PSCustomObject]@{
                Time    = Get-Date
                Message = "High connection count detected"
            }
        }
    }
    catch {
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

    try {

        $Traffic = Get-TrafficSummary

        if (
            $Traffic.Current.InboundMBps -gt $Global:NetPulseSettings.HighTrafficMBps -or
            $Traffic.Current.OutboundMBps -gt $Global:NetPulseSettings.HighTrafficMBps
        ) {

            return "WARNING"
        }

        $Connections = Get-ConnectionsSnapshot

        if (
            $Connections.Statistics.Established -gt
            $Global:NetPulseSettings.HighConnectionCount
        ) {

            return "WARNING"
        }
    }
    catch {
    }

    return "HEALTHY"
}

function Get-NetPulseData {

    $Traffic      = Get-TrafficSummary
    $Connections  = Get-ConnectionsSnapshot
    $Protocols    = Get-ProtocolSummary
    $TopTalkers   = Get-TopTalkersSummary
    $ResolverInfo = Get-ResolverStatistics
    $Events       = Get-NetPulseEvents
    $Status       = Get-NetPulseStatus

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