$files = @(
    "d:\GitHub\DrinkingGame\Scenes\game_hub.tscn",
    "d:\GitHub\DrinkingGame\Scenes\absurd_cards_lobby.tscn",
    "d:\GitHub\DrinkingGame\Scenes\absurd_cards_game.tscn",
    "d:\GitHub\DrinkingGame\Scenes\generate_cards.tscn",
    "d:\GitHub\DrinkingGame\Scenes\mode_selector.tscn",
    "d:\GitHub\DrinkingGame\Scenes\never_have_i_ever_selector.tscn",
    "d:\GitHub\DrinkingGame\Scenes\filters_selector.tscn",
    "d:\GitHub\DrinkingGame\Scenes\custom_pack_editor.tscn",
    "d:\GitHub\DrinkingGame\Scripts\absurd_cards_lobby.gd",
    "d:\GitHub\DrinkingGame\Scripts\absurd_pack_selector.gd"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-Host "Cleaning BOM from $file"
            $newBytes = $bytes[3..($bytes.Length - 1)]
            [System.IO.File]::WriteAllBytes($file, $newBytes)
        } else {
            Write-Host "No BOM found in $file"
        }
    } else {
        Write-Warning "File not found: $file"
    }
}
