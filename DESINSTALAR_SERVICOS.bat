@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════════════
echo    🛑 DESINSTALADOR - GEOCODER 24/7
echo ═══════════════════════════════════════════════════════════════════
echo.
echo Este script vai REMOVER os serviços Windows:
echo   - GeocoderServer
echo   - CloudflareTunnel
echo.
echo ⚠️  Os dados do Nominatim NÃO serão removidos
echo.
pause

echo.
echo Parando serviços...
nssm stop GeocoderServer 2>nul
nssm stop CloudflareTunnel 2>nul
timeout /t 3 /nobreak >nul
echo ✓ Serviços parados

echo.
echo Removendo serviços...
nssm remove GeocoderServer confirm
nssm remove CloudflareTunnel confirm
echo ✓ Serviços removidos

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ✅ DESINSTALAÇÃO CONCLUÍDA
echo ═══════════════════════════════════════════════════════════════════
echo.
echo Para rodar manualmente, use: start_geocoder_permanent.bat
echo.
pause
