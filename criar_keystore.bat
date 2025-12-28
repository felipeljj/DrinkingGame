@echo off
REM Script para criar keystore Android para assinatura de release
REM Execute este script para criar uma keystore para assinar o AAB

echo ========================================
echo   Criar Keystore Android
echo   DrinkingGame - Play Store
echo ========================================
echo.
echo Este script vai criar uma keystore para assinar seu AAB.
echo IMPORTANTE: Guarde a senha em local seguro!
echo.

REM Variável para armazenar o caminho do keytool
set KEYTOOL_PATH=

REM Verificar se keytool está disponível no PATH
where keytool >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set KEYTOOL_PATH=keytool
    goto :found
)

REM Procurar keytool em locais comuns do Java
echo Procurando keytool em locais comuns...

REM Verificar JAVA_HOME
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\keytool.exe" (
        set "KEYTOOL_PATH=%JAVA_HOME%\bin\keytool.exe"
        goto :found
    )
)

REM Procurar em Program Files\Java
for /d %%i in ("C:\Program Files\Java\jdk*") do (
    if exist "%%i\bin\keytool.exe" (
        set "KEYTOOL_PATH=%%i\bin\keytool.exe"
        goto :found
    )
)

REM Procurar em Program Files (x86)\Java
for /d %%i in ("C:\Program Files (x86)\Java\jdk*") do (
    if exist "%%i\bin\keytool.exe" (
        set "KEYTOOL_PATH=%%i\bin\keytool.exe"
        goto :found
    )
)

REM Procurar em C:\Program Files\Java\jre* (às vezes o JDK está aqui)
for /d %%i in ("C:\Program Files\Java\jre*") do (
    if exist "%%i\bin\keytool.exe" (
        set "KEYTOOL_PATH=%%i\bin\keytool.exe"
        goto :found
    )
)

REM Procurar no Android Studio (JDK embarcado)
if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
    set "KEYTOOL_PATH=C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    goto :found
)

REM Procurar no Android Studio (Program Files x86)
if exist "C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe" (
    set "KEYTOOL_PATH=C:\Program Files (x86)\Android\Android Studio\jbr\bin\keytool.exe"
    goto :found
)

REM Procurar no Android Studio (LocalAppData)
if exist "%LOCALAPPDATA%\Android\Sdk\jbr\bin\keytool.exe" (
    set "KEYTOOL_PATH=%LOCALAPPDATA%\Android\Sdk\jbr\bin\keytool.exe"
    goto :found
)

REM Procurar usando where /R (busca recursiva) no Java
for /f "delims=" %%i in ('where /r "C:\Program Files\Java" keytool.exe 2^>nul') do (
    set "KEYTOOL_PATH=%%i"
    goto :found
)

REM Se não encontrou, mostrar erro
echo [ERRO] keytool nao encontrado!
echo.
echo O Java esta instalado, mas o keytool nao foi encontrado.
echo O keytool faz parte do JDK ^(Java Development Kit^), nao do JRE.
echo.
echo Solucoes:
echo.
echo 1. Instalar JDK completo:
echo    https://www.oracle.com/java/technologies/downloads/
echo    Ou baixe: https://adoptium.net/ ^(OpenJDK - gratuito^)
echo.
echo 2. Se ja tem JDK instalado, adicione ao PATH:
echo    Adicione: C:\Program Files\Java\jdk-XX\bin ao PATH do sistema
echo.
echo 3. Ou execute manualmente:
echo    "C:\Program Files\Java\jdk-XX\bin\keytool.exe" -genkey -v -keystore android\keystore\drinkinggame-release.keystore -alias drinkinggame -keyalg RSA -keysize 2048 -validity 10000
echo.
pause
exit /b 1

:found
echo [OK] keytool encontrado: %KEYTOOL_PATH%
echo.


REM Criar diretório android/keystore se não existir
if not exist "android\keystore" (
    mkdir "android\keystore"
    echo [OK] Diretorio android\keystore criado
)

echo.
echo Preencha as informacoes solicitadas:
echo.

REM Executar keytool para criar a keystore
"%KEYTOOL_PATH%" -genkey -v -keystore android\keystore\drinkinggame-release.keystore -alias drinkinggame -keyalg RSA -keysize 2048 -validity 10000

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   Keystore criada com sucesso!
    echo ========================================
    echo.
    echo Arquivo: android\keystore\drinkinggame-release.keystore
    echo Alias: drinkinggame
    echo.
    echo IMPORTANTE:
    echo - Guarde o arquivo .keystore em local seguro
    echo - Guarde a senha que voce criou
    echo - Sem a senha, voce NAO podera atualizar o app na Play Store
    echo.
    echo Proximos passos:
    echo 1. Configure a keystore no Godot Editor
    echo    Project -^> Export -^> Android -^> Options
    echo    Procure por "Keystore/Release" e configure:
    echo    - Keystore File: android\keystore\drinkinggame-release.keystore
    echo    - Keystore Password: (a senha que voce criou)
    echo    - Keystore User Alias: drinkinggame
    echo    - Keystore User Password: (a mesma senha)
    echo.
    echo 2. Exporte o AAB novamente (ja estara assinado)
    echo.
    echo 3. Faca upload na Play Console
    echo.
) else (
    echo.
    echo [ERRO] Falha ao criar keystore
    echo Verifique os erros acima
    echo.
)

pause

