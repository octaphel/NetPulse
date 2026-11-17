# ============================================================
# NetPulse - Color Module
# ============================================================

function Get-NetPulseColor {

    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    switch ($Name.ToUpper()) {

        "HEADER"    { return $Global:NetPulseSettings.HeaderColor }
        "SECTION"   { return $Global:NetPulseSettings.SectionColor }
        "LABEL"     { return $Global:NetPulseSettings.LabelColor }
        "VALUE"     { return $Global:NetPulseSettings.ValueColor }
        "HOST"      { return $Global:NetPulseSettings.HostColor }
        "EVENT"     { return $Global:NetPulseSettings.EventColor }

        "HEALTHY"   { return $Global:NetPulseSettings.HealthyColor }
        "WARNING"   { return $Global:NetPulseSettings.WarningColor }
                "CRITICAL"  { return $Global:NetPulseSettings.CriticalColor }
        "UNKNOWN"   { return $Global:NetPulseSettings.UnknownColor }

        default     { return "White" }
    }
}

function Get-StatusColor {

    param(
        [string]$Status
    )

    switch ($Status.ToUpper()) {

        "HEALTHY" {
            return $Global:NetPulseSettings.HealthyColor
        }

        "WARNING" {
            return $Global:NetPulseSettings.WarningColor
        }

        "CRITICAL" {
            return $Global:NetPulseSettings.CriticalColor
        }

        default {
            return "White"
        }
    }
}

Export-ModuleMember -Function `
    Get-NetPulseColor, `
    Get-StatusColor
