@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    🚀 INSTALAÇÃO POR ETAPAS - GEOCODER 24/7
echo ═══════════════════════════════════════════════════════════
echo.
echo Este instalador está dividido em 6 etapas.
echo Execute cada uma em ordem:
echo.
echo [1] ETAPA1_NODEJS.bat          - Instalar Node.js
echo [2] ETAPA2_DEPENDENCIAS.bat    - Instalar pacotes NPM
echo [3] ETAPA3_CLOUDFLARED.bat     - Instalar Cloudflared
echo [4] ETAPA4_CONFIGURAR_TUNNEL.bat - Configurar tunnel
echo [5] ETAPA5_DOCKER.bat          - Docker e Nominatim
echo [6] ETAPA6_SERVICO_WINDOWS.bat - Serviço 24h (opcional)
echo.
echo ═══════════════════════════════════════════════════════════
echo.
echo Ou use INICIAR.bat para testar manualmente.
echo.
echo.
echo Qual etapa deseja executar? (1-6 ou 0 para sair)
set /p etapa="Escolha: "

if "%etapa%"=="0" exit /b 0
if "%etapa%"=="1" call ETAPA1_NODEJS.bat
if "%etapa%"=="2" call ETAPA2_DEPENDENCIAS.bat
if "%etapa%"=="3" call ETAPA3_CLOUDFLARED.bat
if "%etapa%"=="4" call ETAPA4_CONFIGURAR_TUNNEL.bat
if "%etapa%"=="5" call ETAPA5_DOCKER.bat
if "%etapa%"=="6" call ETAPA6_SERVICO_WINDOWS.bat

echo.
echo Pressione qualquer tecla para voltar ao menu...
pause >nul
goto :EOF
