param (
    [string]$Color = "Cyan",
    [int]$RefreshRate = 1,
    [switch]$ShowDate,
    [switch]$Use12HourFormat,
    [switch]$MatrixStyle,
    [switch]$Animated,
    [switch]$Frame,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
TTy-clock for PowerShell ⏰

Parameters:
  -Color              Color of the clock (Cyan, Green, etc.)
  -RefreshRate        Refresh rate in seconds (default: 1)
  -ShowDate           Display current date above the clock
  -Use12HourFormat    Use 12-hour format with AM/PM
  -MatrixStyle        Use matrix-style ASCII digits
  -Animated           Enable flicker animation effect
  -Frame              Draw a box around the clock

Report issues: https://github.com/Regling/ttyclock-4-win/issues/new
"@
    exit
}

# ASCII font styles
$asciiBasic = @{
    " " = @("   ", "   ", "   ")
    "0" = @(" _ ", "| |", "|_|")
    "1" = @("   ", "  |", "  |")
    "2" = @(" _ ", " _|", "|_ ")
    "3" = @(" _ ", " _|", " _|")
    "4" = @("   ", "|_|", "  |")
    "5" = @(" _ ", "|_ ", " _|")
    "6" = @(" _ ", "|_ ", "|_|")
    "7" = @(" _ ", "  |", "  |")
    "8" = @(" _ ", "|_|", "|_|")
    "9" = @(" _ ", "|_|", " _|")
    ":" = @("   ", " o ", " o ")
    "A" = @(" _ ", "|_|", "| |")
    "P" = @(" _ ", "|_|", "|  ")
    "M" = @("|\\/|", "|  |", "|  |")
}

$asciiMatrix = @{
    " " = @("     ", "     ", "     ")
    "0" = @(" ███ ", "█   █", " ███ ")
    "1" = @("  █  ", "  █  ", "  █  ")
    "2" = @("████ ", "  ██ ", "████ ")
    "3" = @("████ ", "  ██ ", "████ ")
    "4" = @("█  █ ", "████ ", "   █ ")
    "5" = @("████ ", "█    ", "████ ")
    "6" = @(" ███ ", "█    ", "████ ")
    "7" = @("████ ", "   █ ", "  █  ")
    "8" = @(" ███ ", "████ ", " ███ ")
    "9" = @("████ ", "█  █ ", " ███ ")
    ":" = @("     ", "  █  ", "  █  ")
    "A" = @(" ███ ", "█████", "█   █")
    "P" = @("████ ", "█  █ ", "████ ")
    "M" = @("█   █", "██ ██", "█   █")
}

if ($MatrixStyle) {
    $asciiDigits = $asciiMatrix
} else {
    $asciiDigits = $asciiBasic
}

$blink = $true

function Get-ClockLines($now) {
    if ($Use12HourFormat) {
        $timeStr = $now.ToString("hh:mm:ss tt")
    } else {
        $timeStr = $now.ToString("HH:mm:ss")
    }

    $lines = @("", "", "")
    foreach ($char in $timeStr.ToCharArray()) {
        $c = "$char"
        if ($c -eq ":" -and $Animated -and -not $blink) {
            $c = " "
        }
        if ($asciiDigits.ContainsKey($c)) {
            for ($i = 0; $i -lt 3; $i++) {
                $lines[$i] += "  " + $asciiDigits[$c][$i]
            }
        }
    }
    return ,$lines
}

function Show-Clock {
    while ($true) {
        Clear-Host
        $now = Get-Date
        $lines = Get-ClockLines $now
        $width = $Host.UI.RawUI.WindowSize.Width
        $pad = [Math]::Floor(($width - $lines[0].Length) / 2)

        if ($ShowDate) {
            $dateStr = $now.ToString("yyyy-MM-dd")
            $datePad = [Math]::Floor(($width - $dateStr.Length) / 2)
            Write-Host (" " * $datePad) + $dateStr -ForegroundColor $Color
        }

        if ($Frame) {
            $border = "+" + ("-" * ($lines[0].Length + 2)) + "+"
            Write-Host (" " * ($pad - 1)) + $border
            foreach ($line in $lines) {
                Write-Host (" " * ($pad - 1)) + "| " + $line + " |" -ForegroundColor $Color
            }
            Write-Host (" " * ($pad - 1)) + $border
        } else {
            foreach ($line in $lines) {
                Write-Host (" " * $pad) + $line -ForegroundColor $Color
            }
        }

        $blink = -not $blink
        Start-Sleep -Seconds $RefreshRate
    }
}

Show-Clock
