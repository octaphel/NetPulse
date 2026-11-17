$Global:NetPulseSettings = @{

    ############################################################
    # Refresh
    ############################################################

    RefreshInterval = 1

    ############################################################
    # History
    ############################################################

    HistoryLength = 8

    HistoryScale = @(
        '.'
        '_'
        '-'
        '='
        '+'
        '*'
        '#'
        '@'
    )

    HistoryLegend = "Low ..__--==++**##@@ High"

    ############################################################
    # Dashboard
    ############################################################

    TopTalkerCount = 6

    EventLogSize = 3

    ActiveFlowRows = 6

    MaxHostNameLength = 32

    ############################################################
    # DNS Resolution
    ############################################################

    EnableDNSResolution = $true

    DNSCacheMinutes = 5

    UnknownHostLabel = "Unknown"

    ResolvePrivateAddresses = $false

    ############################################################
    # Network Monitoring
    ############################################################

    TrackTCP = $true

    TrackUDP = $true

    TrackICMP = $true

    ShowLocalConnections = $true

    ############################################################
    # Alerts
    ############################################################

    HighTrafficMBps = 100

    HighConnectionCount = 1000

    WarningFailedConnections = 25

    ############################################################
    # Status Thresholds
    ############################################################

    HealthyColor = "Green"

    WarningColor = "Yellow"

    CriticalColor = "Red"

    ############################################################
    # UI Colors
    ############################################################

    HeaderColor = "Cyan"

    SectionColor = "White"

    LabelColor = "Gray"

    ValueColor = "Green"

    HostColor = "Yellow"

    EventColor = "Magenta"

    ############################################################
    # Usage Bars
    ############################################################

    UsageBarWidth = 10

    UsageBarFilledChar = "|"

    UsageBarEmptyChar = "."

    ############################################################
    # Trend Indicators
    ############################################################

    TrendUp = "[+]"

    TrendDown = "[-]"

    TrendFlat = "[=]"
}
