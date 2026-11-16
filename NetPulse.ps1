# ============================================================
# NetPulse
# Main Entry Point
# ============================================================

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

# ============================================================
# Configuration
# ============================================================

. "$Root\Config\Settings.ps1"

# ============================================================
# Core
# ============================================================

Import-Module "$Root\Modules\Core\History.psm1" -Force
Import-Module "$Root\Modules\Core\Resolver.psm1" -Force
Import-Module "$Root\Modules\Core\Collector.psm1" -Force

# ============================================================
# Network
# ============================================================

Import-Module "$Root\Modules\Network\Connections.psm1" -Force
Import-Module "$Root\Modules\Network\Traffic.psm1" -Force
Import-Module "$Root\Modules\Network\Protocols.psm1" -Force
Import-Module "$Root\Modules\Network\TopTalkers.psm1" -Force

# ============================================================
# UI
# ============================================================

Import-Module "$Root\Modules\UI\Colors.psm1" -Force
Import-Module "$Root\Modules\UI\Layout.psm1" -Force
Import-Module "$Root\Modules\UI\Rendering.psm1" -Force

# ============================================================
# Startup
# ============================================================

Initialize-Collector

Clear-Host

Write-Host ""
Write-Host "Starting NetPulse..." -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 1

# ============================================================
# Main Loop
# ============================================================

try {

    while ($true) {

        $Data = Get-NetPulseData

        Show-NetPulseDashboard -Data $Data

        $RefreshInterval =
            $Global:NetPulseSettings.RefreshInterval

        if (-not $RefreshInterval) {
            $RefreshInterval = 1
        }

        Start-Sleep -Seconds $RefreshInterval
    }
}
catch {

    Write-Host ""
    Write-Host "================ ERROR ================" -ForegroundColor Red

    Write-Host $_.Exception.Message -ForegroundColor Yellow

    Write-Host ""
    Write-Host "Script:" -ForegroundColor Cyan
    Write-Host $_.InvocationInfo.ScriptName

    Write-Host ""
    Write-Host "Line:" -ForegroundColor Cyan
    Write-Host $_.InvocationInfo.ScriptLineNumber

    Write-Host ""
    Write-Host "Command:" -ForegroundColor Cyan
    Write-Host $_.InvocationInfo.Line

    Write-Host ""
    Write-Host "Position:" -ForegroundColor Cyan
    Write-Host $_.InvocationInfo.PositionMessage

    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Red
}
finally {

    try {
        Reset-Collector
    }
    catch {
    }
}