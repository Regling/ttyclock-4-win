$asciiDigits = @{
    "0" = @(
        " █████ ",
        "██   ██",
        "██   ██",
        "██   ██",
        " █████ "
    )
    "1" = @(
        "   ██  ",
        " ████  ",
        "   ██  ",
        "   ██  ",
        " █████ "
    )
    "2" = @(
        " █████ ",
        "     ██",
        " █████ ",
        "██     ",
        "███████"
    )
    "3" = @(
        " █████ ",
        "     ██",
        " █████ ",
        "     ██",
        " █████ "
    )
    "4" = @(
        "██   ██",
        "██   ██",
        "███████",
        "     ██",
        "     ██"
    )
    "5" = @(
        "███████",
        "██     ",
        "██████ ",
        "     ██",
        "██████ "
    )
    "6" = @(
        " █████ ",
        "██     ",
        "██████ ",
        "██   ██",
        " █████ "
    )
    "7" = @(
        "███████",
        "     ██",
        "    ██ ",
        "   ██  ",
        "  ██   "
    )
    "8" = @(
        " █████ ",
        "██   ██",
        " █████ ",
        "██   ██",
        " █████ "
    )
    "9" = @(
        " █████ ",
        "██   ██",
        " ██████",
        "     ██",
        " █████ "
    )
    ":" = @(
        "       ",
        "   ██  ",
        "       ",
        "   ██  ",
        "       "
    )
}

function Show-CenteredAsciiClock {
    while ($true) {
        Clear-Host
        $time = (Get-Date).ToString("HH:mm:ss")
        $lines = @("", "", "", "", "")

        foreach ($char in $time.ToCharArray()) {
            for ($i = 0; $i -lt 5; $i++) {
                $lines[$i] += " " + $asciiDigits["$char"][$i]
            }
        }

        $windowWidth = $Host.UI.RawUI.WindowSize.Width
        $windowHeight = $Host.UI.RawUI.WindowSize.Height
        $textWidth = ($lines[0]).Length
        $startRow = [Math]::Max(0, [Math]::Floor(($windowHeight - 5) / 2))
        $startCol = [Math]::Max(0, [Math]::Floor(($windowWidth - $textWidth) / 2))

        for ($i = 0; $i -lt $startRow; $i++) {
            Write-Host ""
        }

        foreach ($line in $lines) {
            Write-Host (" " * $startCol) + $line -ForegroundColor Cyan
        }

        Start-Sleep -Seconds 1
    }
}

Show-CenteredAsciiClock
