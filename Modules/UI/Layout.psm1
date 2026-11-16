# ============================================================
# NetPulse - Layout Module
# ============================================================

function Get-NetPulseLayout {

    return [PSCustomObject]@{

        Width = 69

        HeaderHeight = 3

        TrafficHeight = 6

        HistoryHeight = 4

        TalkerHeight = 6

        ActiveFlowHeight =
            $Script:NetPulseSettings.ActiveFlowRows

        FooterHeight = 2
    }
}

Export-ModuleMember -Function `
    Get-NetPulseLayout