@echo off
chcp 65001 >nul
title Geocoder Reverse Server

echo.
echo ========================================
echo   GEOCODER REVERSE - Servidor Local
echo ========================================
echo.

:MENU
echo Escolha uma opção:
echo.
echo [1] Iniciar servidor (porta 3002)
echo [2] Iniciar servidor + túnel público (LocalTunnel)
echo [3] Executar testes
echo [4] Teste de performance
echo [5] Instalar dependências
echo [0] Sair
echo.
set /p opcao="Digite o número da opção: "

if "%opcao%"=="1" goto START_SERVER
if "%opcao%"=="2" goto START_TUNNEL
if "%opcao%"=="3" goto RUN_TESTS
if "%opcao%"=="4" goto PERFORMANCE_TEST
if "%opcao%"=="5" goto INSTALL_DEPS
if "%opcao%"=="0" goto END
goto MENU

:START_SERVER
echo.
echo Iniciando servidor na porta 3002...
echo.
npm start
goto END

:START_TUNNEL
echo.
echo Iniciando servidor + túnel público...
echo.
start "Geocoder Server" cmd /k "npm start"
timeout /t 3 /nobreak >nul
echo.
echo Criando túnel público...
start "LocalTunnel" cmd /k "lt --port 3002"
timeout /t 5 /nobreak >nul
echo.
echo ========================================
echo   URL Pública (pode variar):
echo   https://xxxxx.loca.lt/api/search_reverse
echo.
echo   Acesse o túnel para ver a URL real!
echo ========================================
echo.
pause
goto END

:RUN_TESTS
echo.
echo Executando testes...
echo.
npm test
echo.
pause
goto MENU

:PERFORMANCE_TEST
echo.
echo Executando teste de performance...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0load_test.ps1"
echo.
pause
goto MENU

:INSTALL_DEPS
echo.
echo Instalando dependências...
echo.
npm install
echo.
echo Instalando LocalTunnel...
npm install -g localtunnel
echo.
echo ✓ Dependências instaladas!
echo.
pause
goto MENU

:END
echo.
echo Encerrando...
exit
