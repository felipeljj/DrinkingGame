$files = @(
    "d:\GitHub\DrinkingGame\Scenes\game_hub.tscn",
    "d:\GitHub\DrinkingGame\Scenes\generate_cards.tscn",
    "d:\GitHub\DrinkingGame\Scenes\absurd_cards_game.tscn",
    "d:\GitHub\DrinkingGame\Scenes\mode_selector.tscn",
    "d:\GitHub\DrinkingGame\Scenes\custom_pack_editor.tscn",
    "d:\GitHub\DrinkingGame\Scenes\filters_selector.tscn"
)

foreach ($f in $files) {
    if (Test-Path $f) {
        Write-Host "File: $f"
        $bytes = Get-Content -Path $f -Encoding Byte -TotalCount 16
        $hex = $bytes | ForEach-Object { "{0:X2}" -f $_ }
        Write-Host "Hex: $hex"
        
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-Host "Detected: UTF-8 BOM"
        } elseif ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            Write-Host "Detected: UTF-16 LE BOM"
        } elseif ($bytes -contains 0x00) {
            Write-Host "Detected: Constant NULLs (Likely UTF-16 without BOM or Binary)"
        } else {
            Write-Host "Detected: Likely UTF-8 / ASCII (No BOM)"
        }
        Write-Host "----------------------------------------"
    } else {
        Write-Host "File not found: $f"
    }
}
