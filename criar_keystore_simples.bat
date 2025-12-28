@echo off
echo ========================================
echo   Criar Keystore Android
echo ========================================
echo.
echo IMPORTANTE sobre a senha:
echo - A senha deve ter NO MINIMO 6 caracteres
echo - Use uma senha forte que voce possa lembrar
echo - Guarde essa senha em local seguro!
echo - Sem a senha, voce NAO podera atualizar o app na Play Store
echo.
echo ========================================
echo.
pause

REM Procurar keytool
set "KEYTOOL_PATH="

if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
    set "KEYTOOL_PATH=C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
)

if exist "C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe" (
    set "KEYTOOL_PATH=C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe"
)

if exist "%LOCALAPPDATA%\Android\Sdk\jbr\bin\keytool.exe" (
    set "KEYTOOL_PATH=%LOCALAPPDATA%\Android\Sdk\jbr\bin\keytool.exe"
)

if "%KEYTOOL_PATH%"=="" (
    echo [ERRO] keytool nao encontrado!
    pause
    exit /b 1
)

echo [OK] Usando keytool do Android Studio: %KEYTOOL_PATH%
echo.

REM Criar diretório
if not exist "android\keystore" (
    mkdir "android\keystore"
)

echo.
echo ========================================
echo   Vamos criar a keystore agora!
echo ========================================
echo.
echo Preencha as informacoes solicitadas abaixo.
echo.
echo Lembre-se: A senha precisa ter no minimo 6 caracteres!
echo.
pause
echo.

REM Executar keytool
"%KEYTOOL_PATH%" -genkey -v -keystore android\keystore\drinkinggame-release.keystore -alias drinkinggame -keyalg RSA -keysize 2048 -validity 10000

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   ✅ Keystore criada com SUCESSO!
    echo ========================================
    echo.
    echo Arquivo: android\keystore\drinkinggame-release.keystore
    echo Alias: drinkinggame
    echo.
    echo 📝 PROXIMOS PASSOS:
    echo.
    echo 1. Abra o Godot Editor
    echo 2. Vá em: Project -^> Export
    echo 3. Selecione o preset "Android"
    echo 4. Clique em "Options"
    echo 5. Procure por "Keystore/Release"
    echo 6. Configure:
    echo    - Keystore File: android\keystore\drinkinggame-release.keystore
    echo    - Keystore Password: [a senha que voce criou]
    echo    - Keystore User Alias: drinkinggame
    echo    - Keystore User Password: [a mesma senha]
    echo 7. Exporte o AAB novamente (já estará assinado!)
    echo 8. Faça upload na Play Console
    echo.
) else (
    echo.
    echo [ERRO] Falha ao criar keystore.
    echo Verifique se a senha tem no minimo 6 caracteres.
    echo.
)

pause


