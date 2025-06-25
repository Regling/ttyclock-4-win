param (
    [string]$Color = "Cyan",
    [int]$RefreshRate = 1,
    [string]$Style = "basic",
    [switch]$ShowDate,
    [switch]$Use12HourFormat,
    [switch]$Animated,
    [switch]$Frame,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
TTY-Clock for PowerShell ⏰

Parameters:
  -Color              Clock color (Cyan, Green, etc.)
  -RefreshRate        Refresh rate in seconds (default: 1)
  -ShowDate           Show current date above the clock
  -Use12HourFormat    Use 12-hour format with AM/PM
  -Style              Font style: basic, lcd, ascii
  -Animated           Blink colon every second
  -Frame              Draw a box around the clock
"@
    exit
}

$asciiBasic = @{
    "0"=@(" █████ ","██   ██","██   ██","██   ██"," █████ ")
    "1"=@("   ██  "," ████  ","   ██  ","   ██  "," █████ ")
    "2"=@(" █████ ","     ██"," █████ ","██     ","███████")
    "3"=@(" █████ ","     ██"," █████ ","     ██"," █████ ")
    "4"=@("██   ██","██   ██","███████","     ██","     ██")
    "5"=@("███████","██     ","██████ ","     ██","██████ ")
    "6"=@(" █████ ","██     ","██████ ","██   ██"," █████ ")
    "7"=@("███████","     ██","    ██ ","   ██  ","  ██   ")
    "8"=@(" █████ ","██   ██"," █████ ","██   ██"," █████ ")
    "9"=@(" █████ ","██   ██"," ██████","     ██"," █████ ")
    ":"=@("       ","   ██  ","       ","   ██  ","       ")
    "A"=@(" ███ ","█   █","█████","█   █","█   █")
    "P"=@("████ ","█   █","████ ","█    ","█   ")
    "M"=@("█   █","██ ██","█ █ █","█   █","█   █")
    " "=@("       ","       ","       ","       ","       ")
}

$asciiLCD = @{
    "0"=@(" ▄▀▀▀▄ ", "█   █ █", "█   █ █", "█   █ █", " ▀▄▄▄▀ ")
    "1"=@("   ▄   ", " ▄█   ", "  █   ", "  █   ", "▄███▄ ")
    "2"=@("▄▀▀▀▄ ", "    █ ", "  ▄▀  ", " █    ", "█████ ")
    "3"=@("▄▀▀▀▄ ", "    █ ", "  ▄▀  ", "    █ ", "▀▄▄▄▀ ")
    "4"=@("█   █ ", "█   █ ", "█████ ", "    █ ", "    █ ")
    "5"=@("█████ ", "█     ", "████  ", "    █ ", "████  ")
    "6"=@(" ▄▀▀▀ ", "█     ", "████▄ ", "█   █ ", " ▀▀▀  ")
    "7"=@("█████ ", "    █ ", "   █  ", "  █   ", " █    ")
    "8"=@(" ▄▀▀▄ ", "█   █ ", " ▀▀▀  ", "█   █ ", " ▀▀▀  ")
    "9"=@(" ▄▀▀▄ ", "█   █ ", " ▀▀██ ", "    █ ", " ▀▀▀  ")
    ":"=@("       ", "   ▀   ", "       ", "   ▄   ", "       ")
    "A"=@(" ▄▀▀▄ ", "█   █ ", "█████ ", "█   █ ", "█   █ ")
    "P"=@("████▄ ", "█   █ ", "████▀ ", "█     ", "█     ")
    "M"=@("█▀▄▀█", "█ ▀ █", "█   █", "█   █", "█   █")
    " "=@("       ", "       ", "       ", "       ", "       ")
}

$asciiLine = @{
    "0"=@(" /‾‾‾‾\ ","|     |","|     |","|     |"," \_____/")
    "1"=@("   /|  ","  / |  ","    |  ","    |  ","  __|__")
    "2"=@(" /‾‾‾‾\ ","     / ","  /‾‾  "," /     "," \_____/")
    "3"=@(" /‾‾‾‾\ ","     / ","  ‾‾‾\ ","     \ "," \____/ ")
    "4"=@("|    | ","|    | "," \____| ","     | ","     | ")
    "5"=@("|‾‾‾‾‾ ","|      "," \‾‾‾\ ","     | "," \____/ ")
    "6"=@(" /‾‾‾  ","|      ","|‾‾‾\ ","|    | "," \____/ ")
    "7"=@("‾‾‾‾‾| ","    /  ","   /   ","  /    "," /     ")
    "8"=@(" /‾‾‾\ ","|   | "," \‾‾‾/ ","|   | "," \___/ ")
    "9"=@(" /‾‾‾\ ","|   | "," \‾‾‾| ","     | "," \___/ ")
    ":"=@("       ","   ░   ","       ","   ░   ","       ")
    "A"=@("  /‾\  "," /   \ ","|‾‾‾‾|","|     |","|     |")
    "P"=@("|‾‾‾\ ","|    |","|‾‾‾/ ","|     ","|     ")
    "M"=@("|\   /|","| \_/ |","|     |","|     |","|     |")
    " "=@("       ","       ","       ","       ","       ")
}

$asciiStyles = @{
    "basic" = $asciiBasic
    "lcd"   = $asciiLCD
    "ascii" = $asciiLine
}

if (-not $asciiStyles.ContainsKey($Style.ToLower())) {
    Write-Host "⚠️ Стиль '$Style' не знайдено. Використовується 'basic'." -ForegroundColor Yellow
    $asciiDigits = $asciiBasic
} else {
    $asciiDigits = $asciiStyles[$Style.ToLower()]
}

$blink = $true

function Get-ClockLines($now) {
    $timeStr = if ($Use12HourFormat) {
        $now.ToString("hh:mm:ss tt")
    } else {
        $now.ToString("HH:mm:ss")
    }

    $lines = @("", "", "", "", "")
    foreach ($char in $timeStr.ToCharArray()) {
        $c = if ($char -eq ":" -and $Animated -and -not $blink) { " " } else { "$char" }
        if (-not $asciiDigits.ContainsKey($c)) {
            Write-Host "⚠️ The '$c' character is not supported for the style '$Style'." -ForegroundColor DarkYellow
            continue
        }
        for ($i = 0; $i -lt 5; $i++) {
            $lines[$i] += "  " + $asciiDigits[$c][$i]
        }
    }
    return $lines
}

function Show-Clock {
    while ($true) {
        Clear-Host
        $now = Get-Date
        $lines = Get-ClockLines $now
        $width = $Host.UI.RawUI.WindowSize.Width
        if ($width -lt 95) {
            Write-Host "`n❗ The PowerShell window is too narrow for a watch" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }

        Clear-Host
        $now = Get-Date
        $pad = [Math]::Floor(($width - $lines[0].Length) / 2)

        if ($ShowDate) {
            $dateStr = $now.ToString("yyyy-MM-dd")
            $datePad = [Math]::Floor(($width - $dateStr.Length) / 2)
            Write-Host (" " * $datePad) + $dateStr -ForegroundColor $Color
        }

        if ($Frame) {
            $border = "+" + ("-" * ($lines[0].Length + 8)) + "+"
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