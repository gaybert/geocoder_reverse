@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════════════
echo    📊 STATUS - GEOCODER 24/7
echo ═══════════════════════════════════════════════════════════════════
echo.

echo 🔍 Verificando serviços Windows...
echo.
echo GeocoderServer:
sc query GeocoderServer | findstr "STATE"
echo.
echo CloudflareTunnel:
sc query CloudflareTunnel | findstr "STATE"
echo.

echo ═══════════════════════════════════════════════════════════════════
echo 🐳 Docker Containers:
echo ═══════════════════════════════════════════════════════════════════
echo.
docker ps --filter "name=nominatim-mato-grosso" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.

echo ═══════════════════════════════════════════════════════════════════
echo 🌐 Testando Endpoints:
echo ═══════════════════════════════════════════════════════════════════
echo.

echo 1. Servidor Local (porta 3002):
powershell -Command "try { $r = Invoke-RestMethod -Uri 'http://localhost:3002/health' -TimeoutSec 5; Write-Host '   ✓ OK - Status:' $r.status -ForegroundColor Green } catch { Write-Host '   ✗ Erro:' $_.Exception.Message -ForegroundColor Red }"
echo.

echo 2. Nominatim Local (porta 8080):
powershell -Command "try { $r = Invoke-RestMethod -Uri 'http://localhost:8080/status.php' -TimeoutSec 5; Write-Host '   ✓ OK - Status:' $r.status -ForegroundColor Green } catch { Write-Host '   ✗ Erro:' $_.Exception.Message -ForegroundColor Red }"
echo.

echo 3. URL Permanente (Internet):
powershell -Command "try { $r = Invoke-RestMethod -Uri 'https://geocoder.urbanmt.com.br/health' -TimeoutSec 10; Write-Host '   ✓ OK - Status:' $r.status -ForegroundColor Green } catch { Write-Host '   ✗ Erro:' $_.Exception.Message -ForegroundColor Red }"
echo.

echo 4. Teste Geocoding (Matupá, MT):
powershell -Command "try { $r = Invoke-RestMethod -Uri 'https://geocoder.urbanmt.com.br/api/search_reverse?latitude=-10.166061&longitude=-54.935305' -TimeoutSec 15; Write-Host '   ✓ OK -' $r.results[0].city ',' $r.results[0].state -ForegroundColor Green } catch { Write-Host '   ✗ Erro:' $_.Exception.Message -ForegroundColor Red }"
echo.

echo ═══════════════════════════════════════════════════════════════════
echo 📝 Logs Recentes:
echo ═══════════════════════════════════════════════════════════════════
echo.

if exist "%~dp0logs\server.log" (
    echo Últimas 5 linhas do servidor:
    powershell -Command "Get-Content '%~dp0logs\server.log' -Tail 5"
) else (
    echo   ⚠️  Arquivo de log não encontrado
)

echo.
echo ═══════════════════════════════════════════════════════════════════
echo 💡 Comandos Úteis:
echo ═══════════════════════════════════════════════════════════════════
echo.
echo   Ver log completo:       type logs\server.log
echo   Ver log do tunnel:      type logs\tunnel.log
echo   Reiniciar servidor:     nssm restart GeocoderServer
echo   Reiniciar tunnel:       nssm restart CloudflareTunnel
echo   Ver logs Docker:        docker logs nominatim-mato-grosso
echo.
pause
