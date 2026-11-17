# ============================================================
# NetPulse - Traffic Module
# ============================================================

$Script:PreviousTrafficSample = $null

# ============================================================
# Get Adapter Statistics
# ============================================================

function Get-AdapterTrafficStatistics {

    $Adapters = Get-NetAdapter |
        Where-Object Status -eq "Up"

    $Results = @()

    foreach ($Adapter in $Adapters) {

        try {

            $Stats = Get-NetAdapterStatistics `
                -Name $Adapter.Name `
                -ErrorAction Stop

            $Results += [PSCustomObject]@{

                Name = $Adapter.Name

                ReceivedBytes =
                    $Stats.ReceivedBytes

                SentBytes =
                    $Stats.SentBytes

                ReceivedPackets =
                    $Stats.ReceivedUnicastPackets +
                    $Stats.ReceivedBroadcastPackets +
                    $Stats.ReceivedMulticastPackets

                SentPackets =
                    $Stats.SentUnicastPackets +
                    $Stats.SentBroadcastPackets +
                    $Stats.SentMulticastPackets
            }
        }
        catch {

            continue
        }
    }

    return $Results
}

# ============================================================
# Get Current Snapshot
# ============================================================

function Get-TrafficSnapshot {

    $CurrentTime = Get-Date

    $CurrentStats = Get-AdapterTrafficStatistics

    if (-not $Script:PreviousTrafficSample) {

        $Script:PreviousTrafficSample = @{
            Timestamp  = $CurrentTime
            Statistics = $CurrentStats
        }

        return [PSCustomObject]@{

            InboundMBps     = 0
            OutboundMBps    = 0

            InboundBytes    = 0
            OutboundBytes   = 0

            PacketsPerSecond = 0

            InterfaceCount = $CurrentStats.Count

            Timestamp = $CurrentTime
        }
    }

    $ElapsedSeconds =
        ($CurrentTime -
        $Script:PreviousTrafficSample.Timestamp).TotalSeconds

    if ($ElapsedSeconds -le 0) {
        $ElapsedSeconds = 1
    }

    $InboundBytes = 0
    $OutboundBytes = 0
    $Packets = 0

    foreach ($Current in $CurrentStats) {

        $Previous =
            $Script:PreviousTrafficSample.Statistics |
            Where-Object Name -eq $Current.Name |
            Select-Object -First 1

        if (-not $Previous) {
            continue
        }

        #
        # Handle adapter counter resets
        #

        $InboundDelta =
            ($Current.ReceivedBytes -
             $Previous.ReceivedBytes)

        $OutboundDelta =
            ($Current.SentBytes -
             $Previous.SentBytes)

        if ($InboundDelta -lt 0) {
            $InboundDelta = 0
        }

        if ($OutboundDelta -lt 0) {
            $OutboundDelta = 0
        }

        $InboundBytes += $InboundDelta
        $OutboundBytes += $OutboundDelta

        #
        # Handle packet counter resets
        #

        $PacketDelta =
            (
                ($Current.ReceivedPackets -
                 $Previous.ReceivedPackets) +

                ($Current.SentPackets -
                 $Previous.SentPackets)
            )

        if ($PacketDelta -lt 0) {
            $PacketDelta = 0
        }

        $Packets += $PacketDelta
    }

    $InboundMBps =
        ($InboundBytes / 1MB) / $ElapsedSeconds

    $OutboundMBps =
        ($OutboundBytes / 1MB) / $ElapsedSeconds

    $PacketsPerSecond =
        [Math]::Round(
            ($Packets / $ElapsedSeconds),
            0
        )

    $Script:PreviousTrafficSample = @{
        Timestamp  = $CurrentTime
        Statistics = $CurrentStats
    }

    return [PSCustomObject]@{

        InboundBytes  = $InboundBytes
        OutboundBytes = $OutboundBytes

        InboundMBps =
            [Math]::Round($InboundMBps, 2)

        OutboundMBps =
            [Math]::Round($OutboundMBps, 2)

        PacketsPerSecond =
            $PacketsPerSecond

        InterfaceCount =
            $CurrentStats.Count

        Timestamp =
            $CurrentTime
    }
}

# ============================================================
# Update Traffic Histories
# ============================================================

function Update-TrafficHistory {

    param (

        [Parameter(Mandatory)]
        [object]$TrafficData
    )

    Add-HistoryValue `
        -Metric "Inbound" `
        -Value $TrafficData.InboundMBps

    Add-HistoryValue `
        -Metric "Outbound" `
        -Value $TrafficData.OutboundMBps

    Add-HistoryValue `
        -Metric "Packets" `
        -Value $TrafficData.PacketsPerSecond
}

# ============================================================
# Get Traffic Summary
# ============================================================

function Get-TrafficSummary {

    $Traffic = Get-TrafficSnapshot

    Update-TrafficHistory $Traffic

    return [PSCustomObject]@{

        Current = $Traffic

        InboundHistory =
            Get-HistoryGraph "Inbound"

        OutboundHistory =
            Get-HistoryGraph "Outbound"

        PacketHistory =
            Get-HistoryGraph "Packets"
    }
}

# ============================================================
# Reset Counters
# ============================================================

function Reset-TrafficModule {

    $Script:PreviousTrafficSample = $null
}

# ============================================================
# Export Members
# ============================================================

Export-ModuleMember -Function `
    Get-AdapterTrafficStatistics, `
    Get-TrafficSnapshot, `
    Update-TrafficHistory, `
    Get-TrafficSummary, `
    Reset-TrafficModule