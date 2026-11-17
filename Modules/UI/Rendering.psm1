# ============================================================
# NetPulse - Rendering Module
# ============================================================

# ============================================================
# Helpers
# ============================================================

function Format-Value {

    param(
        $Value,
        [int]$Width = 0
    )

    $Text = "$Value"

    if ($Width -gt 0) {
        return $Text.PadRight($Width)
    }

    return $Text
}

# ============================================================
# Draw Header
# ============================================================

function Show-NetPulseHeader {

    param(
        [object]$Data
    )

    Write-Host "+---------------------------------------------------------------------+" -ForegroundColor DarkGray

    $Header =
        "¦ NETPULSE  Status: {0,-8}  Refresh: {1}s ¦" -f `
        $Data.Status,
        $Global:NetPulseSettings.RefreshInterval

    Write-Host $Header -ForegroundColor Cyan

    Write-Host "+---------------------------------------------------------------------¦" -ForegroundColor DarkGray
}

# ============================================================
# Traffic Section
# ============================================================

function Show-TrafficSection {

    param(
        [object]$Traffic,
        [object]$Connections,
        [object[]]$Events
    )

    $InValue =
        ("{0:N2} MB/s" -f $Traffic.Current.InboundMBps)

    $OutValue =
        ("{0:N2} MB/s" -f $Traffic.Current.OutboundMBps)

    $PktValue =
        $Traffic.Current.PacketsPerSecond

    $EventText = ""

    if ($Events.Count -gt 0) {
        $EventText = $Events[0].Message
    }

    Write-Host (
        "¦ [ TRAFFIC ]          ¦ [ CONNECTIONS ]      ¦ [ EVENTS ]            ¦"
    )

    Write-Host (
        "¦ IN   {0,-14}¦ ESTABLISHED {1,-8}¦ {2,-21}¦" -f
        $InValue,
        $Connections.Statistics.Established,
        $EventText
    )

    Write-Host (
        "¦ OUT  {0,-14}¦ TIME_WAIT   {1,-8}¦                       ¦" -f
        $OutValue,
        $Connections.Statistics.TimeWait
    )

    Write-Host (
        "¦ PKT/s {0,-12} ¦ SYN_SENT    {1,-8}¦                       ¦" -f
        $PktValue,
        $Connections.Statistics.SynSent
    )

    Write-Host (
        "¦                      ¦ UDP        {0,-8}¦                       ¦" -f
        $Connections.Statistics.UDPEndpoints
    )

    Write-Host "+----------------------+----------------------+-----------------------¦" -ForegroundColor DarkGray
}

# ============================================================
# History Section
# ============================================================

function Show-HistorySection {

    param(
        [object]$Traffic
    )

    Write-Host "¦ [ INBOUND ]          ¦ [ OUTBOUND ]         ¦ [ PACKETS ]           ¦"

    Write-Host (
        "¦ {0,-20} ¦ {1,-20} ¦ {2,-20}¦" -f
        $Traffic.InboundHistory,
        $Traffic.OutboundHistory,
        $Traffic.PacketHistory
    )

    Write-Host (
        "¦                      ¦                      ¦                       ¦"
    )

    Write-Host "+---------------------------------------------+-----------------------¦" -ForegroundColor DarkGray
}

# ============================================================
# Top Talkers + Protocols
# ============================================================

function Show-TopTalkersAndProtocols {

    param(
        [object]$Talkers,
        [object]$Protocols
    )

    Write-Host (
        "¦ [ TOP TALKERS ]                             ¦ [ PROTOCOLS ]         ¦"
    )

    $Rows = [Math]::Max(
        $Talkers.Talkers.Count,
        3
    )

    for ($i = 0; $i -lt $Rows; $i++) {

        $LeftText = ""

        if ($i -lt $Talkers.Talkers.Count) {

            $Entry = $Talkers.Talkers[$i]

            $LeftText = (
                "{0,-20} {1} {2,4}" -f
                $Entry.Name,
                $Entry.Trend,
                $Entry.Connections
            )
        }

        switch ($i) {

            0 {
                $RightText =
                    ("TCP  {0} {1,5}%" -f
                    $Protocols.TCP.UsageBar,
                    $Protocols.TCP.Percentage)
            }

            1 {
                $RightText =
                    ("UDP  {0} {1,5}%" -f
                    $Protocols.UDP.UsageBar,
                    $Protocols.UDP.Percentage)
            }

            2 {
                $RightText =
                    ("ICMP {0} {1,5}%" -f
                    $Protocols.ICMP.UsageBar,
                    $Protocols.ICMP.Percentage)
            }

            default {
                $RightText = ""
            }
        }

        Write-Host (
            "¦ {0,-42} ¦ {1,-21}¦" -f
            $LeftText,
            $RightText
        )
    }

    Write-Host "+---------------------------------------------------------------------¦" -ForegroundColor DarkGray
}

# ============================================================
# Active Flows
# ============================================================

function Show-ActiveFlows {

    param(
        [object[]]$Flows
    )

    Write-Host "¦ [ ACTIVE FLOWS ]                                                    ¦"

    $MaxRows =
        $Global:NetPulseSettings.ActiveFlowRows

    for ($i = 0; $i -lt $MaxRows; $i++) {

        if ($i -lt $Flows.Count) {

            $Flow = $Flows[$i]

            $Name = $Flow.ServiceName

            if ([string]::IsNullOrWhiteSpace($Name)) {
                $Name = $Flow.RemoteAddress
            }

            $Text = (
                "{0}: {1}" -f
                $Name,
                $Flow.RemotePort
            )

            Write-Host (
                "¦ {0,-66} ¦" -f
                $Text
            )
        }
        else {

            Write-Host (
                "¦                                                                  ¦"
            )
        }
    }

    Write-Host "+---------------------------------------------------------------------+" -ForegroundColor DarkGray
}

# ============================================================
# Footer
# ============================================================

function Show-NetPulseFooter {

    Write-Host ""

    Write-Host (
        "History Scale: Low ..__--==++**##@@ High"
    ) -ForegroundColor DarkGray

    Write-Host (
        "Press CTRL+C to exit"
    ) -ForegroundColor DarkGray
}

# ============================================================
# Main Renderer
# ============================================================

function Show-NetPulseDashboard {

    param(
        [Parameter(Mandatory)]
        [object]$Data
    )

    Clear-Host

    Show-NetPulseHeader $Data

    Show-TrafficSection `
        -Traffic $Data.Traffic `
        -Connections $Data.Connections `
        -Events $Data.Events

    Show-HistorySection `
        -Traffic $Data.Traffic

    Show-TopTalkersAndProtocols `
        -Talkers $Data.TopTalkers `
        -Protocols $Data.Protocols

    Show-ActiveFlows `
        -Flows $Data.Connections.ActiveFlows

    Show-NetPulseFooter
}

# ============================================================
# Export
# ============================================================

Export-ModuleMember -Function `
    Show-NetPulseDashboard
