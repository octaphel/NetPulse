# ============================================================
# NetPulse - History Module
# ============================================================

$Script:HistoryStore = @{}

# ============================================================
# Initialize History
# ============================================================

function Initialize-History {

    param (
        [string[]]$Metrics
    )

    foreach ($Metric in $Metrics) {

        if (-not $Script:HistoryStore.ContainsKey($Metric)) {
            $Script:HistoryStore[$Metric] = @()
        }
    }
}

# ============================================================
# Add History Value
# ============================================================

function Add-HistoryValue {

    param (
        [Parameter(Mandatory)]
        [string]$Metric,

        [Parameter(Mandatory)]
        [double]$Value
    )

    if (-not $Script:HistoryStore.ContainsKey($Metric)) {
        $Script:HistoryStore[$Metric] = @()
    }

    $HistoryLength = $Global:NetPulseSettings.HistoryLength

    $Script:HistoryStore[$Metric] += $Value

    if ($Script:HistoryStore[$Metric].Count -gt $HistoryLength) {

        $Script:HistoryStore[$Metric] =
            @($Script:HistoryStore[$Metric] |
            Select-Object -Last $HistoryLength)
    }
}

# ============================================================
# Get History Values
# ============================================================

function Get-HistoryValues {

    param (
        [Parameter(Mandatory)]
        [string]$Metric
    )

    if (-not $Script:HistoryStore.ContainsKey($Metric)) {
        return @()
    }

    return $Script:HistoryStore[$Metric]
}

# ============================================================
# Clear History
# ============================================================

function Clear-History {

    $Script:HistoryStore = @{}
}

# ============================================================
# Convert History To Graph
# ============================================================

function ConvertTo-HistoryGraph {

    param (
        [double[]]$Values
    )

    if (-not $Values -or $Values.Count -eq 0) {
        return ""
    }

    $Scale = $Global:NetPulseSettings.HistoryScale

    $Min = ($Values | Measure-Object -Minimum).Minimum
    $Max = ($Values | Measure-Object -Maximum).Maximum

    if ($Max -eq $Min) {
        return ($Scale[0] * $Values.Count)
    }

    $Graph = ""

    foreach ($Value in $Values) {

        $Normalized =
            ($Value - $Min) /
            ($Max - $Min)

        $Index =
            [Math]::Floor(
                $Normalized * ($Scale.Count - 1)
            )

        $Index =
            [Math]::Max(
                0,
                [Math]::Min(
                    $Index,
                    $Scale.Count - 1
                )
            )

        $Graph += $Scale[$Index]
    }

    return $Graph
}

# ============================================================
# Get History Graph
# ============================================================

function Get-HistoryGraph {

    param (
        [Parameter(Mandatory)]
        [string]$Metric
    )

    $Values = Get-HistoryValues $Metric

    return ConvertTo-HistoryGraph -Values $Values
}

# ============================================================
# Export Module Members
# ============================================================

Export-ModuleMember -Function `
    Initialize-History, `
    Add-HistoryValue, `
    Get-HistoryValues, `
    Get-HistoryGraph, `
    ConvertTo-HistoryGraph, `
    Clear-History
