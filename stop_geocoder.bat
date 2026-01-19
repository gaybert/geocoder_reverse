@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    🛑 PARAR GEOCODER + CLOUDFLARE TUNNEL
echo ═══════════════════════════════════════════════════════════
echo.

echo Parando todos os processos...
echo.

taskkill /F /IM node.exe 2>nul && echo ✓ Node.js parado || echo ℹ Node.js não estava rodando
taskkill /F /IM cloudflared.exe 2>nul && echo ✓ Cloudflared parado || echo ℹ Cloudflared não estava rodando

echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ TUDO PARADO!
echo ═══════════════════════════════════════════════════════════
echo.
pause
