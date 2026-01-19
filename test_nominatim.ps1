# Script de Teste - Nominatim Local
# Verifica se o Nominatim está pronto e testa a API

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  TESTE NOMINATIM LOCAL" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Verificar se container está rodando
Write-Host "1. Verificando container..." -ForegroundColor Yellow
$container = docker ps --filter "name=nominatim-mato-grosso" --format "{{.Status}}"

if ($container) {
    Write-Host "   ✓ Container rodando: $container" -ForegroundColor Green
} else {
    Write-Host "   ✗ Container não encontrado!" -ForegroundColor Red
    Write-Host "`n   Execute primeiro:" -ForegroundColor Yellow
    Write-Host "   docker start nominatim-mato-grosso`n" -ForegroundColor White
    exit
}

# 2. Testar se Nominatim está respondendo
Write-Host "`n2. Testando Nominatim..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/status.php" -TimeoutSec 5 -ErrorAction Stop
    
    if ($response.status -eq 0) {
        Write-Host "   ✓ Nominatim está PRONTO!" -ForegroundColor Green -BackgroundColor DarkGreen
        
        # 3. Testar reverse geocoding (Cuiabá, MT)
        Write-Host "`n3. Testando Reverse Geocoding (Cuiabá, MT)..." -ForegroundColor Yellow
        
        $geo = Invoke-RestMethod -Uri "http://localhost:8080/reverse?lat=-15.5989&lon=-56.0949&format=json" -ErrorAction Stop
        
        Write-Host "   ✓ Funcionando!" -ForegroundColor Green
        Write-Host "`n   Resultado:" -ForegroundColor Cyan
        Write-Host "   Local: $($geo.display_name)" -ForegroundColor White
        
        # 4. Instruções de configuração
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "  CONFIGURAR SEU SERVIDOR" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        
        Write-Host "`n1. Edite o arquivo .env:" -ForegroundColor Yellow
        Write-Host @"
   PORT=3002
   PROVIDER_DEFAULT=openstreetmap
   OSM_SERVER=http://localhost:8080
   OSM_USER_AGENT=geocoder-mato-grosso
"@ -ForegroundColor White
        
        Write-Host "`n2. Reinicie o servidor:" -ForegroundColor Yellow
        Write-Host "   npm start" -ForegroundColor White
        
        Write-Host "`n3. Teste no n8n:" -ForegroundColor Yellow
        Write-Host "   https://great-bears-press.loca.lt/api/search_reverse" -ForegroundColor White
        Write-Host "   Query Parameters:" -ForegroundColor Gray
        Write-Host "     latitude  = -15.5989" -ForegroundColor Gray
        Write-Host "     longitude = -56.0949" -ForegroundColor Gray
        Write-Host "     provider  = openstreetmap" -ForegroundColor Gray
        
        Write-Host "`n========================================" -ForegroundColor Green
        Write-Host "  ✓ NOMINATIM PRONTO E FUNCIONANDO!" -ForegroundColor Green
        Write-Host "  GEOCODING ILIMITADO E GRATUITO!" -ForegroundColor Green
        Write-Host "========================================`n" -ForegroundColor Green
        
    } else {
        Write-Host "   ⏳ Nominatim ainda está importando..." -ForegroundColor Yellow
        Write-Host "`n   Status code: $($response.status)" -ForegroundColor Gray
        Write-Host "   Aguarde mais um pouco e teste novamente.`n" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   ⏳ Nominatim ainda NÃO está pronto" -ForegroundColor Yellow
    Write-Host "`n   A importação ainda está em andamento." -ForegroundColor Gray
    Write-Host "   Isso pode levar 1-2 horas na primeira vez.`n" -ForegroundColor Gray
    
    Write-Host "📋 Acompanhe o progresso:" -ForegroundColor Cyan
    Write-Host "   docker logs -f nominatim-mato-grosso" -ForegroundColor White
    Write-Host "`n   Procure por:" -ForegroundColor Gray
    Write-Host "   - 'Setup finished' = PRONTO!" -ForegroundColor Green
    Write-Host "   - 'Starting Apache' = Servidor iniciando" -ForegroundColor Yellow
    Write-Host "`n   Execute este script novamente quando terminar.`n" -ForegroundColor Gray
}

Write-Host "========================================`n" -ForegroundColor Cyan
