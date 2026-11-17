# ============================================================
# NetPulse - Rendering Module
# Canvas-Based Fixed Layout Renderer
# PowerShell 5.1 Compatible
# ============================================================

function New-Canvas {
    param(
        [int]$Width,
        [int]$Height
    )

    $Canvas = @()

    for ($Y = 0; $Y -lt $Height; $Y++) {
        $Canvas += ,([char[]](' ' * $Width))
    }

    return $Canvas
}

function Set-CanvasText {
    param(
        [object]$Canvas,
        [int]$X,
        [int]$Y,
        [string]$Text,
        [int]$MaxWidth
    )

    if ($Y -lt 0 -or $Y -ge $Canvas.Count) {
        return
    }

    if ($MaxWidth -lt 1) {
        return
    }

    if ($null -eq $Text) {
        $Text = ""
    }

    if ($Text.Length -gt $MaxWidth) {
        $Text = $Text.Substring(0, $MaxWidth)
    }

    $Text = $Text.PadRight($MaxWidth)

    for ($I = 0; $I -lt $Text.Length; $I++) {

        $Pos = $X + $I

        if (
            $Pos -ge 0 -and
            $Pos -lt $Canvas[$Y].Length
        ) {
            $Canvas[$Y][$Pos] = $Text[$I]
        }
    }
}

function Draw-Panel {
    param(
        [object]$Canvas,
        [object]$Panel,
        [string]$Title
    )

    $Left   = $Panel.X
    $Top    = $Panel.Y
    $Width  = $Panel.Width
    $Height = $Panel.Height

    $Right  = $Left + $Width - 1
    $Bottom = $Top + $Height - 1

    $Canvas[$Top][$Left] = '+'
    $Canvas[$Top][$Right] = '+'
    $Canvas[$Bottom][$Left] = '+'
    $Canvas[$Bottom][$Right] = '+'

    for ($X = $Left + 1; $X -lt $Right; $X++) {
        $Canvas[$Top][$X] = '-'
        $Canvas[$Bottom][$X] = '-'
    }

    for ($Y = $Top + 1; $Y -lt $Bottom; $Y++) {
        $Canvas[$Y][$Left] = '|'
        $Canvas[$Y][$Right] = '|'
    }

    if ($Title) {
        $TitleText = "[ $Title ]"

        $Available = $Width - 4

        if ($TitleText.Length -gt $Available) {
            $TitleText = $TitleText.Substring(0, $Available)
        }

        Set-CanvasText `
            -Canvas $Canvas `
            -X ($Left + 2) `
            -Y $Top `
            -Text $TitleText `
            -MaxWidth $Available
    }
}

function Write-PanelLines {
    param(
        [object]$Canvas,
        [object]$Panel,
        [string[]]$Lines
    )

    $InnerWidth  = $Panel.Width - 2
    $InnerHeight = $Panel.Height - 2

    for ($Row = 0; $Row -lt $InnerHeight; $Row++) {

        $Text = ""

        if ($Row -lt $Lines.Count) {
            $Text = "$($Lines[$Row])"
        }

        Set-CanvasText `
            -Canvas $Canvas `
            -X ($Panel.X + 1) `
            -Y ($Panel.Y + 1 + $Row) `
            -Text $Text `
            -MaxWidth $InnerWidth
    }
}

function Convert-CanvasToLines {
    param(
        [object]$Canvas
    )

    foreach ($Row in $Canvas) {
        -join $Row
    }
}

function Show-NetPulseDashboard {
    param(
        [Parameter(Mandatory)]
        [object]$Data
    )

    $Layout = Get-NetPulseLayout

    $Canvas = New-Canvas `
        -Width $Layout.Canvas.Width `
        -Height $Layout.Canvas.Height

    Draw-Panel $Canvas $Layout.Header      "NETPULSE"
    Draw-Panel $Canvas $Layout.Traffic     "TRAFFIC"
    Draw-Panel $Canvas $Layout.Connections "CONNECTIONS"
    Draw-Panel $Canvas $Layout.Events      "EVENTS"
    Draw-Panel $Canvas $Layout.History     "HISTORY"
    Draw-Panel $Canvas $Layout.TopTalkers  "TOP TALKERS"
    Draw-Panel $Canvas $Layout.Protocols   "PROTOCOLS"
    Draw-Panel $Canvas $Layout.ActiveFlows "ACTIVE FLOWS"
    Draw-Panel $Canvas $Layout.Footer      "INFO"

    # Header

    $HeaderLines = @(
        ("Status: {0}" -f $Data.Status)
        ("Refresh: {0}s" -f $Global:NetPulseSettings.RefreshInterval)
    )

    Write-PanelLines $Canvas $Layout.Header $HeaderLines

    # Traffic

    $TrafficLines = @(
        ("Inbound  : {0:N2} MB/s" -f $Data.Traffic.Current.InboundMBps)
        ("Outbound : {0:N2} MB/s" -f $Data.Traffic.Current.OutboundMBps)
        ("Packets  : {0}" -f $Data.Traffic.Current.PacketsPerSecond)
        ("NICs     : {0}" -f $Data.Traffic.Current.InterfaceCount)
    )

    Write-PanelLines $Canvas $Layout.Traffic $TrafficLines

    # Connections

    $ConnLines = @(
        ("TCP      : {0}" -f $Data.Connections.Statistics.TCPConnections)
        ("UDP      : {0}" -f $Data.Connections.Statistics.UDPEndpoints)
        ("ESTAB    : {0}" -f $Data.Connections.Statistics.Established)
        ("LISTEN   : {0}" -f $Data.Connections.Statistics.Listen)
        ("SYN_SENT : {0}" -f $Data.Connections.Statistics.SynSent)
        ("TIMEWAIT : {0}" -f $Data.Connections.Statistics.TimeWait)
    )

    Write-PanelLines $Canvas $Layout.Connections $ConnLines

    # Events

    $EventLines = @()

    foreach ($Event in $Data.Events) {
        $EventLines += $Event.Message
    }

    Write-PanelLines $Canvas $Layout.Events $EventLines

    # History

    $HistoryLines = @(
        ("Inbound : {0}" -f $Data.Traffic.InboundHistory)
        ("Outbound: {0}" -f $Data.Traffic.OutboundHistory)
        ("Packets : {0}" -f $Data.Traffic.PacketHistory)
    )

    Write-PanelLines $Canvas $Layout.History $HistoryLines

    # Top Talkers

    $TalkerLines = @()

    foreach ($Talker in $Data.TopTalkers.Talkers) {

        $TalkerLines += (
            "{0} {1} {2}" -f
            $Talker.Name,
            $Talker.Trend,
            $Talker.Connections
        )
    }

    Write-PanelLines $Canvas $Layout.TopTalkers $TalkerLines

    # Protocols

    $ProtocolLines = @(
        ("TCP  {0} {1}%" -f $Data.Protocols.TCP.UsageBar,$Data.Protocols.TCP.Percentage)
        ("UDP  {0} {1}%" -f $Data.Protocols.UDP.UsageBar,$Data.Protocols.UDP.Percentage)
        ("ICMP {0} {1}%" -f $Data.Protocols.ICMP.UsageBar,$Data.Protocols.ICMP.Percentage)
        ""
        ("TCP Count  : {0}" -f $Data.Protocols.TCP.Count)
        ("UDP Count  : {0}" -f $Data.Protocols.UDP.Count)
        ("ICMP Count : {0}" -f $Data.Protocols.ICMP.Count)
    )

    Write-PanelLines $Canvas $Layout.Protocols $ProtocolLines

    # Active Flows

    $FlowLines = @()

    foreach ($Flow in $Data.Connections.ActiveFlows) {

        $Name = $Flow.ServiceName

        if ([string]::IsNullOrWhiteSpace($Name)) {
            $Name = $Flow.RemoteAddress
        }

        $FlowLines += (
            "{0}:{1}" -f
            $Name,
            $Flow.RemotePort
        )
    }

    Write-PanelLines $Canvas $Layout.ActiveFlows $FlowLines

    # Footer

    $FooterLines = @(
        $Global:NetPulseSettings.HistoryLegend
    )

    Write-PanelLines $Canvas $Layout.Footer $FooterLines

    Clear-Host

    foreach ($Line in (Convert-CanvasToLines $Canvas)) {
        Write-Host $Line
    }
}

Export-ModuleMember -Function Show-NetPulseDashboard