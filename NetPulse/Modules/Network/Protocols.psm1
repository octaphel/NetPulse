# ============================================================
# NetPulse - Protocols Module
# ============================================================

# ============================================================
# Build Usage Bar
# ============================================================

function New-UsageBar {

    param (
        [Parameter(Mandatory)]
        [double]$Percentage
    )

    $Width = $Script:NetPulseSettings.UsageBarWidth

    $Filled =
        [Math]::Round(
            ($Percentage / 100) * $Width
        )

    if ($Filled -lt 0) {
        $Filled = 0
    }

    if ($Filled -gt $Width) {
        $Filled = $Width
    }

    $Empty = $Width - $Filled

    $Bar =
        "[" +
        ($Script:NetPulseSettings.UsageBarFilledChar * $Filled) +
        ($Script:NetPulseSettings.UsageBarEmptyChar * $Empty) +
        "]"

    return $Bar
}

# ============================================================
# Get Protocol Counts
# ============================================================

function Get-ProtocolCounts {

    $TCPCount = 0
    $UDPCount = 0

    try {

        if ($Script:NetPulseSettings.TrackTCP) {

            $TCPCount =
                (Get-NetTCPConnection).Count
        }
    }
    catch {
        $TCPCount = 0
    }

    try {

        if ($Script:NetPulseSettings.TrackUDP) {

            $UDPCount =
                (Get-NetUDPEndpoint).Count
        }
    }
    catch {
        $UDPCount = 0
    }

    #
    # Placeholder
    # Real ICMP monitoring can come later.
    #

    $ICMPCount = 0

    return [PSCustomObject]@{

        TCP   = $TCPCount
        UDP   = $UDPCount
        ICMP  = $ICMPCount
    }
}

# ============================================================
# Convert Counts To Percentages
# ============================================================

function Get-ProtocolDistribution {

    $Counts = Get-ProtocolCounts

    $Total =
        $Counts.TCP +
        $Counts.UDP +
        $Counts.ICMP

    if ($Total -le 0) {

        return [PSCustomObject]@{

            TCPPercent  = 0
            UDPPercent  = 0
            ICMPPercent = 0

            TCPCount  = 0
            UDPCount  = 0
            ICMPCount = 0
        }
    }

    $TCPPercent =
        [Math]::Round(
            ($Counts.TCP / $Total) * 100,
            1
        )

    $UDPPercent =
        [Math]::Round(
            ($Counts.UDP / $Total) * 100,
            1
        )

    $ICMPPercent =
        [Math]::Round(
            ($Counts.ICMP / $Total) * 100,
            1
        )

    return [PSCustomObject]@{

        TCPPercent  = $TCPPercent
        UDPPercent  = $UDPPercent
        ICMPPercent = $ICMPPercent

        TCPCount  = $Counts.TCP
        UDPCount  = $Counts.UDP
        ICMPCount = $Counts.ICMP
    }
}

# ============================================================
# Get Protocol Summary
# ============================================================

function Get-ProtocolSummary {

    $Distribution =
        Get-ProtocolDistribution

    return [PSCustomObject]@{

        TCP = [PSCustomObject]@{

            Count      = $Distribution.TCPCount
            Percentage = $Distribution.TCPPercent
            UsageBar   = New-UsageBar `
                -Percentage $Distribution.TCPPercent
        }

        UDP = [PSCustomObject]@{

            Count      = $Distribution.UDPCount
            Percentage = $Distribution.UDPPercent
            UsageBar   = New-UsageBar `
                -Percentage $Distribution.UDPPercent
        }

        ICMP = [PSCustomObject]@{

            Count      = $Distribution.ICMPCount
            Percentage = $Distribution.ICMPPercent
            UsageBar   = New-UsageBar `
                -Percentage $Distribution.ICMPPercent
        }

        Timestamp = Get-Date
    }
}

# ============================================================
# Export Module Members
# ============================================================

Export-ModuleMember -Function `
    New-UsageBar, `
    Get-ProtocolCounts, `
    Get-ProtocolDistribution, `
    Get-ProtocolSummary