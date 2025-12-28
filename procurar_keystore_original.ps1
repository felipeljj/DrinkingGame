# Script para procurar a keystore original da Play Console
# Procura em todos os locais comuns e verifica o SHA1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Procurando Keystore Original" -ForegroundColor Cyan
Write-Host "  Play Console" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$targetSHA1 = "B6:FE:39:7E:AB:E9:25:91:CA:16:9F:F7:B0:87:D1:EF:52:FB:E0:30"
Write-Host "SHA1 Esperado: $targetSHA1" -ForegroundColor Yellow
Write-Host ""

# Encontrar keytool
$keytoolPath = $null
$keytoolPaths = @(
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe",
    "$env:LOCALAPPDATA\Android\Sdk\jbr\bin\keytool.exe"
)

foreach ($path in $keytoolPaths) {
    if (Test-Path $path) {
        $keytoolPath = $path
        break
    }
}

if (-not $keytoolPath) {
    Write-Host "[ERRO] keytool nao encontrado!" -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Host "[OK] Usando keytool: $keytoolPath" -ForegroundColor Green
Write-Host ""

# Locais para procurar
$searchLocations = @(
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\.android",
    "$env:USERPROFILE\AndroidStudioProjects",
    "$env:USERPROFILE\OneDrive",
    "$env:USERPROFILE\Dropbox",
    "$env:USERPROFILE\Google Drive",
    "C:\Android",
    "C:\Projects",
    "C:\Users\$env:USERNAME\Documents\GitHub"
)

Write-Host "Procurando keystores em:" -ForegroundColor Cyan
foreach ($loc in $searchLocations) {
    if (Test-Path $loc) {
        Write-Host "  - $loc" -ForegroundColor Gray
    }
}
Write-Host ""

$foundKeystores = @()
$foundTarget = $false

foreach ($location in $searchLocations) {
    if (-not (Test-Path $location)) {
        continue
    }
    
    Write-Host "Procurando em: $location..." -ForegroundColor Yellow
    
    try {
        $keystores = Get-ChildItem -Path $location -Recurse -Include "*.keystore","*.jks" -ErrorAction SilentlyContinue -Depth 3
        
        foreach ($keystore in $keystores) {
            Write-Host "  Encontrada: $($keystore.FullName)" -ForegroundColor Gray
            
            try {
                # Tentar listar a keystore (sem senha para ver se consegue ler)
                $output = & $keytoolPath -list -v -keystore $keystore.FullName 2>&1 | Out-String
                
                # Tentar extrair SHA1 de diferentes formatos
                $sha1 = $null
                if ($output -match "SHA1:\s*([0-9A-F:]+)") {
                    $sha1 = $matches[1].Trim().ToUpper()
                } elseif ($output -match "SHA1 \(.+?\):\s*([0-9A-F:]+)") {
                    $sha1 = $matches[1].Trim().ToUpper()
                }
                
                if ($sha1) {
                    $foundKeystores += [PSCustomObject]@{
                        Path = $keystore.FullName
                        SHA1 = $sha1
                        Size = $keystore.Length
                        Date = $keystore.LastWriteTime
                    }
                    
                    if ($sha1 -eq $targetSHA1) {
                        Write-Host ""
                        Write-Host "========================================" -ForegroundColor Green
                        Write-Host "  ✅ KEYSTORE ORIGINAL ENCONTRADA!" -ForegroundColor Green
                        Write-Host "========================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "Arquivo: $($keystore.FullName)" -ForegroundColor Cyan
                        Write-Host "SHA1: $sha1" -ForegroundColor Cyan
                        Write-Host "Tamanho: $([math]::Round($keystore.Length/1KB, 2)) KB" -ForegroundColor Cyan
                        Write-Host "Data: $($keystore.LastWriteTime)" -ForegroundColor Cyan
                        Write-Host ""
                        Write-Host "Esta e a keystore que voce precisa usar!" -ForegroundColor Yellow
                        $foundTarget = $true
                    } else {
                        Write-Host "    SHA1: $sha1 (nao e a correta)" -ForegroundColor DarkGray
                    }
                } else {
                    Write-Host "    (Nao foi possivel ler o SHA1 - pode precisar de senha)" -ForegroundColor DarkYellow
                }
            } catch {
                Write-Host "    (Erro ao verificar - pode precisar de senha)" -ForegroundColor DarkYellow
            }
        }
    } catch {
        Write-Host "  (Erro ao acessar: $($_.Exception.Message))" -ForegroundColor DarkRed
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Resumo da Busca" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($foundTarget) {
    Write-Host "✅ Keystore original ENCONTRADA!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximos passos:" -ForegroundColor Yellow
    Write-Host "1. Copie esta keystore para um local seguro"
    Write-Host "2. Configure no Godot Editor"
    Write-Host "3. Use a SENHA correta desta keystore"
    Write-Host "4. Exporte o AAB novamente"
} else {
    Write-Host "❌ Keystore original NAO encontrada nos locais pesquisados." -ForegroundColor Red
    Write-Host ""
    
    if ($foundKeystores.Count -gt 0) {
        Write-Host "Keystores encontradas (mas com SHA1 diferente):" -ForegroundColor Yellow
        foreach ($ks in $foundKeystores) {
            Write-Host "  - $($ks.Path)" -ForegroundColor Gray
            Write-Host "    SHA1: $($ks.SHA1)" -ForegroundColor DarkGray
            Write-Host "    Tamanho: $([math]::Round($ks.Size/1KB, 2)) KB | Data: $($ks.Date)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
    
    Write-Host "Sugestoes:" -ForegroundColor Yellow
    Write-Host "- Procure em backups (HD externo, nuvem)"
    Write-Host "- Verifique se outro desenvolvedor tem a keystore"
    Write-Host "- Procure em projetos antigos do Android Studio"
    Write-Host "- Verifique emails ou documentacao sobre a keystore original"
    Write-Host ""
    Write-Host "⚠️  SEM a keystore original, voce NAO podera atualizar o app existente!" -ForegroundColor Red
}

Write-Host ""
Read-Host "Pressione Enter para sair"



