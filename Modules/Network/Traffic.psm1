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
            Timestamp = $CurrentTime
            Statistics = $CurrentStats
        }

        return [PSCustomObject]@{

            InboundMBps  = 0
            OutboundMBps = 0

            InboundBytes  = 0
            OutboundBytes = 0

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

        $InboundBytes +=
            ($Current.ReceivedBytes -
             $Previous.ReceivedBytes)

        $OutboundBytes +=
            ($Current.SentBytes -
             $Previous.SentBytes)

        $Packets +=
            (
                ($Current.ReceivedPackets -
                 $Previous.ReceivedPackets) +

                ($Current.SentPackets -
                 $Previous.SentPackets)
            )
    }

    $InboundMBps =
        ($InboundBytes / 1MB) / $ElapsedSeconds

    $OutboundMBps =
        ($OutboundBytes / 1MB) / $ElapsedSeconds

    $PacketsPerSecond =
        [math]::Round(
            ($Packets / $ElapsedSeconds),
            0
        )

    $Script:PreviousTrafficSample = @{
        Timestamp = $CurrentTime
        Statistics = $CurrentStats
    }

    return [PSCustomObject]@{

        InboundBytes = $InboundBytes
        OutboundBytes = $OutboundBytes

        InboundMBps =
            [math]::Round($InboundMBps, 2)

        OutboundMBps =
            [math]::Round($OutboundMBps, 2)

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