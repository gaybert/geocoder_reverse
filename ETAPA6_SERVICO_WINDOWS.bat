@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    ETAPA 6: INSTALAR COMO SERVIÇO WINDOWS (24H)
echo    (Opcional - Execute como ADMINISTRADOR)
echo ═══════════════════════════════════════════════════════════
echo.

where nssm >nul 2>&1
if %errorlevel% neq 0 (
    echo Instalando NSSM (gerenciador de serviços)...
    echo.
    powershell -Command "Invoke-WebRequest -Uri 'https://nssm.cc/release/nssm-2.24.zip' -OutFile '%TEMP%\nssm.zip'; Expand-Archive -Path '%TEMP%\nssm.zip' -DestinationPath '%TEMP%\nssm' -Force; Copy-Item '%TEMP%\nssm\nssm-2.24\win64\nssm.exe' 'C:\Windows\System32\nssm.exe' -Force"
    
    if %errorlevel% neq 0 (
        echo.
        echo ✗ Erro ao instalar NSSM!
        echo   Execute este script como ADMINISTRADOR
        echo.
        echo Pressione qualquer tecla para sair...
        pause >nul
        exit /b 1
    )
    
    echo ✓ NSSM instalado
)

echo.
echo Removendo serviços antigos (se existirem)...
nssm stop GeocoderServer 2>nul
nssm stop CloudflareTunnel 2>nul
timeout /t 2 /nobreak >nul
nssm remove GeocoderServer confirm 2>nul
nssm remove CloudflareTunnel confirm 2>nul

echo.
echo Instalando serviço GeocoderServer...
nssm install GeocoderServer "C:\Program Files\nodejs\node.exe" "%~dp0index.js"
nssm set GeocoderServer AppDirectory "%~dp0"
nssm set GeocoderServer DisplayName "Geocoder Server - urbanmt.com.br"
nssm set GeocoderServer Description "Servidor de geocoding reverso com Nominatim"
nssm set GeocoderServer Start SERVICE_AUTO_START
if not exist "%~dp0logs" mkdir "%~dp0logs"
nssm set GeocoderServer AppStdout "%~dp0logs\server.log"
nssm set GeocoderServer AppStderr "%~dp0logs\server-error.log"
nssm set GeocoderServer AppRotateFiles 1
nssm set GeocoderServer AppRotateBytes 10485760
echo ✓ Serviço GeocoderServer instalado

echo.
echo Instalando serviço CloudflareTunnel...
nssm install CloudflareTunnel "C:\Program Files\cloudflared\cloudflared.exe" "tunnel run geocoder-mt"
nssm set CloudflareTunnel DisplayName "Cloudflare Tunnel - geocoder.urbanmt.com.br"
nssm set CloudflareTunnel Description "Tunnel permanente para geocoder"
nssm set CloudflareTunnel Start SERVICE_AUTO_START
nssm set CloudflareTunnel AppStdout "%~dp0logs\tunnel.log"
nssm set CloudflareTunnel AppStderr "%~dp0logs\tunnel-error.log"
nssm set CloudflareTunnel AppRotateFiles 1
nssm set CloudflareTunnel AppRotateBytes 10485760
echo ✓ Serviço CloudflareTunnel instalado

echo.
echo Iniciando serviços...
nssm start GeocoderServer
nssm start CloudflareTunnel
echo ✓ Serviços iniciados

echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ SERVIÇOS WINDOWS INSTALADOS E INICIADOS!
echo ═══════════════════════════════════════════════════════════
echo.
echo 🌐 URL Permanente: https://geocoder.urbanmt.com.br
echo.
echo 📊 Status dos serviços:
sc query GeocoderServer | findstr "STATE"
sc query CloudflareTunnel | findstr "STATE"
echo.
echo 💡 Os serviços iniciam automaticamente com o Windows!
echo.
echo Ver logs:
echo    type logs\server.log
echo    type logs\tunnel.log
echo.
echo Gerenciar:
echo    nssm start/stop/restart GeocoderServer
echo    nssm start/stop/restart CloudflareTunnel
echo.
echo Remover: DESINSTALAR_SERVICOS.bat
echo.
echo Pressione qualquer tecla para sair...
pause >nul
