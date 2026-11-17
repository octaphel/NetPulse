# ============================================================
# NetPulse - Layout Module
# Canvas Layout Definitions
# ============================================================

function Get-NetPulseLayout {

    [PSCustomObject]@{

        Canvas = [PSCustomObject]@{

            Width  = 100
            Height = 50
        }

        Header = [PSCustomObject]@{

            X      = 0
            Y      = 0
            Width  = 100
            Height = 4
        }

        Traffic = [PSCustomObject]@{

            X      = 0
            Y      = 4
            Width  = 32
            Height = 8
        }

        Connections = [PSCustomObject]@{

            X      = 34
            Y      = 4
            Width  = 32
            Height = 8
        }

        Events = [PSCustomObject]@{

            X      = 68
            Y      = 4
            Width  = 32
            Height = 8
        }

        History = [PSCustomObject]@{

            X      = 0
            Y      = 13
            Width  = 100
            Height = 6
        }

        TopTalkers = [PSCustomObject]@{

            X      = 0
            Y      = 20
            Width  = 66
            Height = 12
        }

        Protocols = [PSCustomObject]@{

            X      = 68
            Y      = 20
            Width  = 32
            Height = 12
        }

        ActiveFlows = [PSCustomObject]@{

            X      = 0
            Y      = 33
            Width  = 100
            Height = 14
        }

        Footer = [PSCustomObject]@{

            X      = 0
            Y      = 47
            Width  = 100
            Height = 3
        }
    }
}

Export-ModuleMember -Function Get-NetPulseLayout