@echo off
REM Script para corrigir automaticamente o AndroidManifest.xml após export do Godot
REM Este script corrige o conflito de maxSdkVersion entre os manifests

echo ========================================
echo   Corrigindo AndroidManifest.xml
echo ========================================
echo.

set "BASE_DIR=%~dp0android\build"
set "FIXED=0"

REM Corrigir manifest principal
if exist "%BASE_DIR%\AndroidManifest.xml" (
    echo [1/3] Corrigindo AndroidManifest.xml principal...
    powershell -Command "(Get-Content '%BASE_DIR%\AndroidManifest.xml') -replace 'android:maxSdkVersion=\"29\"', 'android:maxSdkVersion=\"32\" tools:replace=\"android:maxSdkVersion\"' | Set-Content '%BASE_DIR%\AndroidManifest.xml' -Encoding UTF8"
    powershell -Command "(Get-Content '%BASE_DIR%\AndroidManifest.xml') -replace '<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" android:maxSdkVersion=\"32\" />', '<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" android:maxSdkVersion=\"32\" tools:replace=\"android:maxSdkVersion\" />' | Set-Content '%BASE_DIR%\AndroidManifest.xml' -Encoding UTF8"
    set /a FIXED+=1
    echo   [OK] Manifest principal corrigido
) else (
    echo   [AVISO] Manifest principal nao encontrado
)

REM Corrigir manifest debug
if exist "%BASE_DIR%\src\debug\AndroidManifest.xml" (
    echo [2/3] Corrigindo AndroidManifest.xml debug...
    powershell -Command "(Get-Content '%BASE_DIR%\src\debug\AndroidManifest.xml') -replace 'android:maxSdkVersion=\"29\"', 'android:maxSdkVersion=\"32\" tools:replace=\"android:maxSdkVersion\"' | Set-Content '%BASE_DIR%\src\debug\AndroidManifest.xml' -Encoding UTF8"
    powershell -Command "(Get-Content '%BASE_DIR%\src\debug\AndroidManifest.xml') -replace '<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" android:maxSdkVersion=\"32\" />', '<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" android:maxSdkVersion=\"32\" tools:replace=\"android:maxSdkVersion\" />' | Set-Content '%BASE_DIR%\src\debug\AndroidManifest.xml' -Encoding UTF8"
    set /a FIXED+=1
    echo   [OK] Manifest debug corrigido
) else (
    echo   [AVISO] Manifest debug nao encontrado
)

REM Corrigir manifest release
if exist "%BASE_DIR%\src\release\AndroidManifest.xml" (
    echo [3/3] Corrigindo AndroidManifest.xml release...
    powershell -Command "(Get-Content '%BASE_DIR%\src\release\AndroidManifest.xml') -replace 'android:maxSdkVersion=\"29\"', 'android:maxSdkVersion=\"32\" tools:replace=\"android:maxSdkVersion\"' | Set-Content '%BASE_DIR%\src\release\AndroidManifest.xml' -Encoding UTF8"
    powershell -Command "(Get-Content '%BASE_DIR%\src\release\AndroidManifest.xml') -replace '<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" android:maxSdkVersion=\"32\" />', '<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" android:maxSdkVersion=\"32\" tools:replace=\"android:maxSdkVersion\" />' | Set-Content '%BASE_DIR%\src\release\AndroidManifest.xml' -Encoding UTF8"
    set /a FIXED+=1
    echo   [OK] Manifest release corrigido
) else (
    echo   [AVISO] Manifest release nao encontrado
)

echo.
if %FIXED% GTR 0 (
    echo ========================================
    echo   Correcao concluida!
    echo   %FIXED% arquivo(s) corrigido(s)
    echo ========================================
) else (
    echo ========================================
    echo   Nenhum arquivo foi corrigido
    echo   (Possivelmente ja estao corretos)
    echo ========================================
)

echo.
pause


