# Busca Agressiva pela keystore original
# Procura em TODOS os locais possiveis

Write-Host "========================================" -ForegroundColor Red
Write-Host "  BUSCA INTENSIVA PELA KEYSTORE" -ForegroundColor Red
Write-Host "  Procurando em TODO o sistema..." -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

$targetSHA1 = "B6:FE:39:7E:AB:E9:25:91:CA:16:9F:F7:B0:87:D1:EF:52:FB:E0:30"
Write-Host "SHA1 Esperado: $targetSHA1" -ForegroundColor Yellow
Write-Host ""

# Encontrar keytool
$keytoolPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
if (-not (Test-Path $keytoolPath)) {
    $keytoolPath = "C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe"
}

Write-Host "[OK] Usando keytool: $keytoolPath" -ForegroundColor Green
Write-Host ""

# TODOS os locais possiveis
$allLocations = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\OneDrive",
    "$env:USERPROFILE\Documents\GitHub",
    "$env:USERPROFILE\AndroidStudioProjects",
    "$env:USERPROFILE\.android",
    "$env:LOCALAPPDATA\Android",
    "$env:APPDATA\Android"
)

$foundAll = @()
$foundTarget = $null

foreach ($location in $allLocations) {
    if (-not (Test-Path $location)) {
        continue
    }
    
    Write-Host "Buscando em: $location" -ForegroundColor Cyan
    
    try {
        $files = Get-ChildItem -Path $location -Recurse -Include "*.keystore","*.jks" -ErrorAction SilentlyContinue -Depth 5 -File
        
        foreach ($file in $files) {
            Write-Host "  Encontrado: $($file.FullName)" -ForegroundColor Gray
            
            try {
                $output = & $keytoolPath -list -v -keystore $file.FullName 2>&1 | Out-String
                
                if ($output -match "SHA1:\s*([0-9A-F:]+)") {
                    $sha1 = $matches[1].Trim().ToUpper()
                    
                    Write-Host "    SHA1: $sha1" -ForegroundColor White
                    
                    $foundAll += [PSCustomObject]@{
                        Path = $file.FullName
                        SHA1 = $sha1
                        Size = $file.Length
                        Date = $file.LastWriteTime
                    }
                    
                    if ($sha1 -eq $targetSHA1) {
                        Write-Host ""
                        Write-Host "========================================" -ForegroundColor Green
                        Write-Host "  KEYSTORE ENCONTRADA!!!" -ForegroundColor Green
                        Write-Host "========================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "ARQUIVO: $($file.FullName)" -ForegroundColor Yellow
                        Write-Host "SHA1: $sha1" -ForegroundColor Yellow
                        Write-Host "Tamanho: $([math]::Round($file.Length/1KB, 2)) KB" -ForegroundColor Yellow
                        Write-Host "Data: $($file.LastWriteTime)" -ForegroundColor Yellow
                        Write-Host ""
                        $foundTarget = $file.FullName
                    }
                } else {
                    Write-Host "    Nao foi possivel ler SHA1 (pode precisar de senha)" -ForegroundColor DarkYellow
                    $foundAll += [PSCustomObject]@{
                        Path = $file.FullName
                        SHA1 = "NAO LIDO (precisa senha)"
                        Size = $file.Length
                        Date = $file.LastWriteTime
                    }
                }
            } catch {
                Write-Host "    Erro ao verificar (pode precisar de senha)" -ForegroundColor DarkYellow
            }
        }
    } catch {
        Write-Host "  Erro ao acessar: $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESULTADO DA BUSCA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($foundTarget) {
    Write-Host "KEYSTORE ORIGINAL ENCONTRADA!!!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Use esta keystore no Godot:" -ForegroundColor Yellow
    Write-Host "$foundTarget" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "Keystore original NAO encontrada" -ForegroundColor Red
    Write-Host ""
    
    if ($foundAll.Count -gt 0) {
        Write-Host "Todas as keystores encontradas:" -ForegroundColor Yellow
        Write-Host ""
        foreach ($ks in $foundAll) {
            Write-Host "Arquivo: $($ks.Path)" -ForegroundColor Gray
            Write-Host "SHA1: $($ks.SHA1)" -ForegroundColor DarkGray
            Write-Host "Tamanho: $([math]::Round($ks.Size/1KB, 2)) KB | Data: $($ks.Date)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
    
    Write-Host "Sugestoes finais:" -ForegroundColor Yellow
    Write-Host "- Verifique emails antigos sobre o app" -ForegroundColor White
    Write-Host "- Pergunte a outros desenvolvedores" -ForegroundColor White
    Write-Host "- Procure em HD externo ou pendrive" -ForegroundColor White
    Write-Host "- Verifique backups na nuvem" -ForegroundColor White
    Write-Host "- Verifique na Play Console: Configuracao -> Assinatura do app" -ForegroundColor White
    Write-Host ""
}

Read-Host "Pressione Enter para sair"
