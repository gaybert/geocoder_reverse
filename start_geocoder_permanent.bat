@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    🌍 GEOCODER - TUNNEL PERMANENTE
echo    https://geocoder.urbanmt.com.br
echo ═══════════════════════════════════════════════════════════
echo.

echo [1/3] Limpando processos antigos...
taskkill /F /IM node.exe 2>nul
taskkill /F /IM cloudflared.exe 2>nul
timeout /t 2 /nobreak >nul
echo       ✓ Processos limpos
echo.

echo [2/3] Iniciando servidor na porta 3002...
start "SERVIDOR GEOCODER" cmd /k "cd /d %~dp0 && color 0A && echo. && echo  🚀 GEOCODER SERVER && echo     URL: https://geocoder.urbanmt.com.br && echo     Porta Local: 3002 && echo     0,0 = cidade não informada && echo. && npm start"
timeout /t 6 /nobreak >nul
echo       ✓ Servidor iniciado
echo.

echo [3/3] Iniciando Cloudflare Tunnel...
start "CLOUDFLARE TUNNEL PERMANENTE" cmd /k "cd /d %~dp0 && color 0B && echo. && echo  ☁️  CLOUDFLARE TUNNEL PERMANENTE && echo     URL FIXA: https://geocoder.urbanmt.com.br && echo     Tunnel: geocoder-mt && echo. && cloudflared tunnel run geocoder-mt"
timeout /t 8 /nobreak >nul
echo       ✓ Tunnel iniciado
echo.

echo ═══════════════════════════════════════════════════════════
echo    ✅ TUDO PRONTO!
echo ═══════════════════════════════════════════════════════════
echo.
echo 🌐 URL PERMANENTE (nunca muda):
echo    https://geocoder.urbanmt.com.br
echo.
echo 📊 Endpoints disponíveis:
echo    https://geocoder.urbanmt.com.br/health
echo    https://geocoder.urbanmt.com.br/api/search_reverse
echo.
echo 💡 Mantenha as 2 janelas abertas:
echo    - Janela VERDE  = Servidor (porta 3002)
echo    - Janela AZUL   = Cloudflare Tunnel
echo.
echo 🔄 Para reiniciar: execute este arquivo novamente
echo 🛑 Para parar: execute stop_geocoder.bat
echo.
pause
