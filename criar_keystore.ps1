# Script PowerShell para criar keystore Android
# Este script funciona melhor para input interativo

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Criar Keystore Android" -ForegroundColor Cyan
Write-Host "  DrinkingGame - Play Store" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IMPORTANTE sobre a senha:" -ForegroundColor Yellow
Write-Host "- A senha deve ter NO MINIMO 6 caracteres" -ForegroundColor Yellow
Write-Host "- Use uma senha forte que voce possa lembrar" -ForegroundColor Yellow
Write-Host "- Guarde essa senha em local seguro!" -ForegroundColor Yellow
Write-Host "- Sem a senha, voce NAO podera atualizar o app na Play Store" -ForegroundColor Red
Write-Host ""

# Procurar keytool
$keytoolPath = $null

$paths = @(
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe",
    "$env:LOCALAPPDATA\Android\Sdk\jbr\bin\keytool.exe"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        $keytoolPath = $path
        break
    }
}

if (-not $keytoolPath) {
    Write-Host "[ERRO] keytool nao encontrado!" -ForegroundColor Red
    Write-Host "Procure por keytool.exe no Android Studio"
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Host "[OK] Usando keytool do Android Studio: $keytoolPath" -ForegroundColor Green
Write-Host ""

# Criar diretório
$keystoreDir = Join-Path $PSScriptRoot "android\keystore"
if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null
    Write-Host "[OK] Diretorio criado: $keystoreDir" -ForegroundColor Green
}

$keystoreFile = Join-Path $keystoreDir "drinkinggame-release.keystore"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Vamos criar a keystore agora!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Lembre-se: A senha precisa ter no minimo 6 caracteres!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Voce sera solicitado a preencher:" -ForegroundColor Cyan
Write-Host "1. Senha da keystore (minimo 6 caracteres)"
Write-Host "2. Confirmacao da senha"
Write-Host "3. Nome completo"
Write-Host "4. Unidade organizacional (pode deixar vazio - Enter)"
Write-Host "5. Organizacao (ex: Drink's Deck)"
Write-Host "6. Cidade"
Write-Host "7. Estado"
Write-Host "8. Codigo do pais (BR para Brasil)"
Write-Host "9. Confirmar informacoes (digite: yes)"
Write-Host "10. Senha do alias (geralmente a mesma da keystore)"
Write-Host ""
Read-Host "Pressione Enter para continuar"

Write-Host ""
Write-Host "Executando keytool..." -ForegroundColor Green
Write-Host ""

# Executar keytool
& $keytoolPath -genkey -v `
    -keystore $keystoreFile `
    -alias drinkinggame `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Keystore criada com SUCESSO!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Arquivo: $keystoreFile" -ForegroundColor Cyan
    Write-Host "Alias: drinkinggame" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Abra o Godot Editor"
    Write-Host "2. Va em: Project -> Export"
    Write-Host "3. Selecione o preset 'Android'"
    Write-Host "4. Clique em 'Options'"
    Write-Host "5. Procure por 'Keystore/Release'"
    Write-Host "6. Configure:"
    Write-Host "   - Keystore File: $keystoreFile" -ForegroundColor Gray
    Write-Host "   - Keystore Password: [a senha que voce criou]"
    Write-Host "   - Keystore User Alias: drinkinggame"
    Write-Host "   - Keystore User Password: [a mesma senha]"
    Write-Host "7. Exporte o AAB novamente (ja estara assinado!)"
    Write-Host "8. Faca upload na Play Console"
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "[ERRO] Falha ao criar keystore." -ForegroundColor Red
    Write-Host "Verifique se a senha tem no minimo 6 caracteres." -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "Pressione Enter para sair"


