# ============================================================
# NetPulse - Resolver Module
# ============================================================

$Script:DNSCache = @{}
$Script:KnownServices = @{}

# ============================================================
# Initialize Resolver
# ============================================================

function Initialize-Resolver {

    $Script:KnownServices = @{

        "github.com"            = "GitHub"
        "api.github.com"        = "GitHub"

        "discord.com"           = "Discord"
        "discord.gg"            = "Discord"

        "google.com"            = "Google"
        "dns.google"            = "Google DNS"

        "youtube.com"           = "YouTube"
        "googlevideo.com"       = "YouTube"

        "steamcontent.com"      = "Steam"
        "steampowered.com"      = "Steam"

        "microsoft.com"         = "Microsoft"
        "windowsupdate.com"     = "Windows Update"
        "office.com"            = "Microsoft 365"

        "cloudflare.com"        = "Cloudflare"

        "amazonaws.com"         = "AWS"

        "facebook.com"          = "Facebook"
        "instagram.com"         = "Instagram"
        "whatsapp.net"          = "WhatsApp"

        "reddit.com"            = "Reddit"

        "openai.com"            = "OpenAI"
    }
}

# ============================================================
# Test Private IP
# ============================================================

function Test-PrivateIPAddress {

    param (
        [string]$IPAddress
    )

    if ($IPAddress -match '^10\.') {
        return $true
    }

    if ($IPAddress -match '^192\.168\.') {
        return $true
    }

    if ($IPAddress -match '^172\.(1[6-9]|2[0-9]|3[0-1])\.') {
        return $true
    }

    if ($IPAddress -eq "127.0.0.1") {
        return $true
    }

    return $false
}

# ============================================================
# Remove Expired Cache Entries
# ============================================================

function Clear-ExpiredDNSCache {

    $CacheMinutes = $Script:NetPulseSettings.DNSCacheMinutes

    $Now = Get-Date

    foreach ($Key in @($Script:DNSCache.Keys)) {

        $Age = ($Now - $Script:DNSCache[$Key].Timestamp).TotalMinutes

        if ($Age -gt $CacheMinutes) {
            $Script:DNSCache.Remove($Key)
        }
    }
}

# ============================================================
# Resolve Host Name
# ============================================================

function Resolve-HostName {

    param (
        [Parameter(Mandatory)]
        [string]$IPAddress
    )

    if (-not $Script:NetPulseSettings.EnableDNSResolution) {
        return $IPAddress
    }

    if ([string]::IsNullOrWhiteSpace($IPAddress)) {
        return $Script:NetPulseSettings.UnknownHostLabel
    }

    Clear-ExpiredDNSCache

    if ($Script:DNSCache.ContainsKey($IPAddress)) {

        return $Script:DNSCache[$IPAddress].HostName
    }

    if (
        (-not $Script:NetPulseSettings.ResolvePrivateAddresses) -and
        (Test-PrivateIPAddress $IPAddress)
    ) {

        return $IPAddress
    }

    $HostName = $IPAddress

    try {

        $Entry = Resolve-DnsName `
            -Name $IPAddress `
            -ErrorAction Stop

        $PTR = $Entry |
            Where-Object Type -eq PTR |
            Select-Object -First 1

        if ($PTR) {

            $HostName = $PTR.NameHost.TrimEnd('.')
        }
    }
    catch {

        $HostName = $IPAddress
    }

    $Script:DNSCache[$IPAddress] = @{
        HostName  = $HostName
        Timestamp = Get-Date
    }

    return $HostName
}

# ============================================================
# Get Friendly Service Name
# ============================================================

function Get-ServiceName {

    param (
        [Parameter(Mandatory)]
        [string]$HostName
    )

    if ([string]::IsNullOrWhiteSpace($HostName)) {
        return "Unknown"
    }

    $LowerHost = $HostName.ToLower()

    foreach ($Key in $Script:KnownServices.Keys) {

        if ($LowerHost -like "*$Key*") {
            return $Script:KnownServices[$Key]
        }
    }

    return $HostName
}

# ============================================================
# Resolve Endpoint
# ============================================================

function Resolve-NetworkEndpoint {

    param (
        [Parameter(Mandatory)]
        [string]$IPAddress
    )

    $HostName = Resolve-HostName $IPAddress

    $ServiceName = Get-ServiceName $HostName

    return [PSCustomObject]@{

        IPAddress   = $IPAddress
        HostName    = $HostName
        ServiceName = $ServiceName
    }
}

# ============================================================
# Get Cache Statistics
# ============================================================

function Get-ResolverStatistics {

    return [PSCustomObject]@{

        CacheEntries = $Script:DNSCache.Count
    }
}

# ============================================================
# Clear Resolver Cache
# ============================================================

function Clear-ResolverCache {

    $Script:DNSCache = @{}
}

# ============================================================
# Export Members
# ============================================================

Export-ModuleMember -Function `
    Initialize-Resolver, `
    Resolve-HostName, `
    Resolve-NetworkEndpoint, `
    Get-ServiceName, `
    Get-ResolverStatistics, `
    Clear-ResolverCache, `
    Clear-ExpiredDNSCache, `
    Test-PrivateIPAddress