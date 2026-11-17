# ============================================================
# NetPulse - Connections Module
# ============================================================

function Get-NetPulseTCPConnections {

    try {
        @(Get-NetTCPConnection -ErrorAction Stop)
    }
    catch {
        @()
    }
}

function Get-NetPulseUDPEndpoints {

    try {
        @(Get-NetUDPEndpoint -ErrorAction Stop)
    }
    catch {
        @()
    }
}

function Get-TCPStateCounts {

    param(
        [object[]]$Connections
    )

    $Connections = @($Connections)

    [PSCustomObject]@{
        Established = (@($Connections | Where-Object State -eq "Established")).Count
        Listen      = (@($Connections | Where-Object State -eq "Listen")).Count
        SynSent     = (@($Connections | Where-Object State -eq "SynSent")).Count
        SynReceived = (@($Connections | Where-Object State -eq "SynReceived")).Count
        TimeWait    = (@($Connections | Where-Object State -eq "TimeWait")).Count
        CloseWait   = (@($Connections | Where-Object State -eq "CloseWait")).Count
        Closed      = (@($Connections | Where-Object State -eq "Closed")).Count
    }
}

function Get-ActiveFlows {

    $Rows = $Global:NetPulseSettings.ActiveFlowRows

    $Flows = @()

    $Connections = Get-NetPulseTCPConnections

    foreach ($Connection in $Connections) {

        if (
            $Connection.RemoteAddress -in @(
                "0.0.0.0",
                "::",
                "",
                $null
            )
        ) {
            continue
        }

        $Endpoint = Resolve-NetworkEndpoint $Connection.RemoteAddress

        $Flows += [PSCustomObject]@{
            Protocol      = "TCP"
            State         = $Connection.State
            LocalAddress  = $Connection.LocalAddress
            LocalPort     = $Connection.LocalPort
            RemoteAddress = $Connection.RemoteAddress
            RemotePort    = $Connection.RemotePort
            HostName      = $Endpoint.HostName
            ServiceName   = $Endpoint.ServiceName
        }
    }

    @(
        $Flows |
        Sort-Object ServiceName |
        Select-Object -First $Rows
    )
}

function Get-RemoteHostSummary {

    $Connections = Get-NetPulseTCPConnections

    $Results = @()

    $Groups =
        $Connections |
        Where-Object RemoteAddress |
        Group-Object RemoteAddress

    foreach ($Group in $Groups) {

        $Endpoint =
            Resolve-NetworkEndpoint $Group.Name

        $Results += [PSCustomObject]@{
            IPAddress   = $Group.Name
            HostName    = $Endpoint.HostName
            ServiceName = $Endpoint.ServiceName
            Connections = $Group.Count
        }
    }

    $Results |
    Sort-Object Connections -Descending
}

function Get-ConnectionStatistics {

    $TCP = Get-NetPulseTCPConnections
    $UDP = Get-NetPulseUDPEndpoints

    $StateCounts = Get-TCPStateCounts $TCP

    [PSCustomObject]@{
        TCPConnections = @($TCP).Count
        UDPEndpoints   = @($UDP).Count

        Established = $StateCounts.Established
        Listen      = $StateCounts.Listen
        SynSent     = $StateCounts.SynSent
        SynReceived = $StateCounts.SynReceived
        TimeWait    = $StateCounts.TimeWait
        CloseWait   = $StateCounts.CloseWait
        Closed      = $StateCounts.Closed
    }
}

function Get-ConnectionsSnapshot {

    [PSCustomObject]@{
        Statistics = Get-ConnectionStatistics
        ActiveFlows = Get-ActiveFlows
        Hosts = Get-RemoteHostSummary
        Timestamp = Get-Date
    }
}

Export-ModuleMember -Function `
    Get-NetPulseTCPConnections, `
    Get-NetPulseUDPEndpoints, `
    Get-TCPStateCounts, `
    Get-ActiveFlows, `
    Get-RemoteHostSummary, `
    Get-ConnectionStatistics, `
    Get-ConnectionsSnapshot
