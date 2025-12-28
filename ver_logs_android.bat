@echo off
REM Script para visualizar logs do Android no Windows
REM Uso: Clique duas vezes neste arquivo ou execute no terminal

echo ========================================
echo   Visualizador de Logs Android
echo   DrinkingGame - Debug Helper
echo ========================================
echo.

REM Verificar se ADB está disponível
where adb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] ADB nao encontrado!
    echo.
    echo Por favor, instale o Android SDK Platform Tools:
    echo https://developer.android.com/studio/releases/platform-tools
    echo.
    echo Ou adicione o caminho do ADB ao PATH do sistema.
    echo.
    pause
    exit /b 1
)

REM Verificar se dispositivo está conectado
echo Verificando dispositivos conectados...
adb devices
echo.

REM Menu de opções
echo Escolha uma opcao:
echo.
echo 1. Ver todos os logs em tempo real
echo 2. Ver apenas logs do Godot/DrinkingGame
echo 3. Ver apenas erros e warnings
echo 4. Ver logs de crash
echo 5. Limpar logs e ver tudo
echo 6. Salvar logs em arquivo
echo 7. Ver logs customizados (UIManager, etc)
echo.
set /p opcao="Digite o numero da opcao (1-7): "

if "%opcao%"=="1" (
    echo.
    echo Mostrando todos os logs...
    echo Pressione Ctrl+C para parar
    echo.
    adb logcat
)

if "%opcao%"=="2" (
    echo.
    echo Mostrando apenas logs do Godot/DrinkingGame...
    echo Pressione Ctrl+C para parar
    echo.
    adb logcat | findstr /i "godot DrinkingGame"
)

if "%opcao%"=="3" (
    echo.
    echo Mostrando apenas erros e warnings...
    echo Pressione Ctrl+C para parar
    echo.
    adb logcat *:E *:W
)

if "%opcao%"=="4" (
    echo.
    echo Mostrando logs de crash...
    echo Pressione Ctrl+C para parar
    echo.
    adb logcat | findstr /i "FATAL AndroidRuntime crash"
)

if "%opcao%"=="5" (
    echo.
    echo Limpando logs antigos...
    adb logcat -c
    echo.
    echo Mostrando todos os logs (limpos)...
    echo Pressione Ctrl+C para parar
    echo.
    adb logcat
)

if "%opcao%"=="6" (
    set /p nome_arquivo="Digite o nome do arquivo (sem extensao): "
    echo.
    echo Salvando logs em %nome_arquivo%.txt...
    echo Pressione Ctrl+C para parar a captura
    echo.
    adb logcat > %nome_arquivo%.txt
    echo.
    echo Logs salvos em %nome_arquivo%.txt
)

if "%opcao%"=="7" (
    echo.
    echo Mostrando logs customizados do jogo...
    echo Pressione Ctrl+C para parar
    echo.
    adb logcat | findstr /i "UIManager ERROR WARNING"
)

if "%opcao%"=="" (
    echo Opcao invalida!
    pause
    exit /b 1
)

pause


