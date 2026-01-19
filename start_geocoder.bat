@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    🌍 INICIADOR GEOCODER + CLOUDFLARE TUNNEL
echo ═══════════════════════════════════════════════════════════
echo.

echo [1/4] Limpando processos antigos...
taskkill /F /IM node.exe 2>nul
taskkill /F /IM cloudflared.exe 2>nul
timeout /t 2 /nobreak >nul
echo       ✓ Processos limpos
echo.

echo [2/4] Iniciando servidor na porta 3002...
start "SERVIDOR GEOCODER - Porta 3002" cmd /k "cd /d %~dp0 && color 0A && echo. && echo  🚀 SERVIDOR GEOCODER && echo     Porta: 3002 && echo     0,0 = cidade não informada && echo. && npm start"
timeout /t 6 /nobreak >nul
echo       ✓ Servidor iniciado
echo.

echo [3/4] Iniciando Cloudflare Tunnel...
start "CLOUDFLARE TUNNEL" cmd /k "cd /d %~dp0 && color 0B && echo. && echo  ☁️  CLOUDFLARE TUNNEL && echo     Aguarde a URL... && echo. && npx cloudflared tunnel --url http://localhost:3002"
timeout /t 18 /nobreak >nul
echo       ✓ Tunnel iniciado
echo.

echo [4/4] Pronto!
echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ TUDO INICIADO COM SUCESSO!
echo ═══════════════════════════════════════════════════════════
echo.
echo 📋 PROCURE A URL NA JANELA "CLOUDFLARE TUNNEL"
echo    Formato: https://XXXX-XXXX-XXXX.trycloudflare.com
echo.
echo 💡 Mantenha as 2 janelas abertas:
echo    - Janela VERDE  = Servidor
echo    - Janela AZUL   = Cloudflare Tunnel
echo.
echo 🔄 Para reiniciar tudo, execute este arquivo novamente
echo.
pause
