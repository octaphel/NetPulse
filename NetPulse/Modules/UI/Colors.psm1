# ============================================================
# NetPulse - Color Module
# ============================================================

function Get-NetPulseColor {

    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    switch ($Name.ToUpper()) {

        "HEADER"    { return $Script:NetPulseSettings.HeaderColor }
        "SECTION"   { return $Script:NetPulseSettings.SectionColor }
        "LABEL"     { return $Script:NetPulseSettings.LabelColor }
        "VALUE"     { return $Script:NetPulseSettings.ValueColor }
        "HOST"      { return $Script:NetPulseSettings.HostColor }
        "EVENT"     { return $Script:NetPulseSettings.EventColor }

        "HEALTHY"   { return $Script:NetPulseSettings.HealthyColor }
        "WARNING"   { return $Script:NetPulseSettings.WarningColor }
        "CRITICAL"  { return $Script:NetPulseSettings.CriticalColor }

        default     { return "White" }
    }
}

function Get-StatusColor {

    param(
        [string]$Status
    )

    switch ($Status.ToUpper()) {

        "HEALTHY" {
            return $Script:NetPulseSettings.HealthyColor
        }

        "WARNING" {
            return $Script:NetPulseSettings.WarningColor
        }

        "CRITICAL" {
            return $Script:NetPulseSettings.CriticalColor
        }

        default {
            return "White"
        }
    }
}

Export-ModuleMember -Function `
    Get-NetPulseColor, `
    Get-StatusColor