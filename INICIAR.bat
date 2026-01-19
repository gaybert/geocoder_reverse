@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    🚀 INICIAR GEOCODER
echo    https://geocoder.urbanmt.com.br
echo ═══════════════════════════════════════════════════════════
echo.

cd /d "%~dp0"

echo Iniciando servidor...
start "GEOCODER SERVER" cmd /k "npm start"
timeout /t 3 /nobreak >nul

echo Iniciando Cloudflare Tunnel...
start "CLOUDFLARE TUNNEL" cmd /k "cloudflared tunnel run geocoder-mt"
timeout /t 3 /nobreak >nul

echo.
echo ✅ Tudo iniciado!
echo.
echo 🌐 URL: https://geocoder.urbanmt.com.br
echo.
pause
