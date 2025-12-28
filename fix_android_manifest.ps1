# Script PowerShell para corrigir automaticamente o AndroidManifest.xml após export do Godot
# Este script corrige o conflito de maxSdkVersion entre os manifests

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Corrigindo AndroidManifest.xml" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$BaseDir = Join-Path $PSScriptRoot "android\build"
$Fixed = 0

# Função para corrigir um arquivo manifest
function Fix-Manifest {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        
        # Substituir maxSdkVersion="29" por maxSdkVersion="32" com tools:replace
        $content = $content -replace 'android:maxSdkVersion="29"', 'android:maxSdkVersion="32" tools:replace="android:maxSdkVersion"'
        
        # Garantir que já tenha tools:replace mesmo se for 32
        if ($content -match '<uses-permission android:name="android\.permission\.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32"\s*/>') {
            $content = $content -replace '(<uses-permission android:name="android\.permission\.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32"\s*/>)', '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" tools:replace="android:maxSdkVersion" />'
        }
        
        Set-Content $FilePath -Value $content -Encoding UTF8 -NoNewline
        return $true
    }
    return $false
}

# Corrigir manifest principal
$mainManifest = Join-Path $BaseDir "AndroidManifest.xml"
Write-Host "[1/3] Corrigindo AndroidManifest.xml principal..." -ForegroundColor Yellow
if (Fix-Manifest -FilePath $mainManifest) {
    Write-Host "  [OK] Manifest principal corrigido" -ForegroundColor Green
    $Fixed++
} else {
    Write-Host "  [AVISO] Manifest principal nao encontrado" -ForegroundColor Gray
}

# Corrigir manifest debug
$debugManifest = Join-Path $BaseDir "src\debug\AndroidManifest.xml"
Write-Host "[2/3] Corrigindo AndroidManifest.xml debug..." -ForegroundColor Yellow
if (Fix-Manifest -FilePath $debugManifest) {
    Write-Host "  [OK] Manifest debug corrigido" -ForegroundColor Green
    $Fixed++
} else {
    Write-Host "  [AVISO] Manifest debug nao encontrado" -ForegroundColor Gray
}

# Corrigir manifest release
$releaseManifest = Join-Path $BaseDir "src\release\AndroidManifest.xml"
Write-Host "[3/3] Corrigindo AndroidManifest.xml release..." -ForegroundColor Yellow
if (Fix-Manifest -FilePath $releaseManifest) {
    Write-Host "  [OK] Manifest release corrigido" -ForegroundColor Green
    $Fixed++
} else {
    Write-Host "  [AVISO] Manifest release nao encontrado" -ForegroundColor Gray
}

Write-Host ""
if ($Fixed -gt 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Correcao concluida!" -ForegroundColor Green
    Write-Host "  $Fixed arquivo(s) corrigido(s)" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  Nenhum arquivo foi corrigido" -ForegroundColor Yellow
    Write-Host "  (Possivelmente ja estao corretos)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Pressione Enter para sair"


