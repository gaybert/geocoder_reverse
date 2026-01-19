# Instalação do Nominatim Local com Docker
# Geocoding ILIMITADO e GRATUITO!

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  NOMINATIM LOCAL - Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verifica se Docker está instalado
Write-Host "1. Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "   ✓ Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Docker não encontrado!" -ForegroundColor Red
    Write-Host "`n   Instale Docker Desktop:" -ForegroundColor Yellow
    Write-Host "   https://www.docker.com/products/docker-desktop`n" -ForegroundColor White
    exit
}

Write-Host "`n2. Região: Mato Grosso" -ForegroundColor Yellow
Write-Host "   Tamanho: ~200-500MB" -ForegroundColor Green
Write-Host "   Tempo estimado: 15-30 minutos" -ForegroundColor Gray

$region = "brazil"
$size = "~300MB"

# URL específica para extratos do Brasil por estado
# Vamos baixar o Brasil e depois o Nominatim vai indexar apenas o necessário
Write-Host "`n   ⚠️  Nota: Baixaremos Brasil inteiro, mas você pode configurar" -ForegroundColor Yellow
Write-Host "   para focar apenas no Mato Grosso após a instalação." -ForegroundColor Gray

Write-Host "`n3. Criando diretório..." -ForegroundColor Yellow
$nominatimDir = "$PWD\nominatim-data"
if (-not (Test-Path $nominatimDir)) {
    New-Item -ItemType Directory -Path $nominatimDir | Out-Null
    Write-Host "   ✓ Diretório criado: $nominatimDir" -ForegroundColor Green
} else {
    Write-Host "   ✓ Diretório já existe" -ForegroundColor Green
}

Write-Host "`n4. Criando docker-compose.yml..." -ForegroundColor Yellow

$dockerCompose = @"
version: '3'
services:
  nominatim:
    image: mediagis/nominatim:4.4
    container_name: nominatim-local
    ports:
      - "8080:8080"
    environment:
      PBF_URL: https://download.geofabrik.de/south-america/$region-latest.osm.pbf
      REPLICATION_URL: https://download.geofabrik.de/south-america/$region-updates/
      IMPORT_WIKIPEDIA: "false"
      NOMINATIM_PASSWORD: nominatim
    volumes:
      - nominatim-data:/var/lib/postgresql/14/main
    shm_size: 1gb

volumes:
  nominatim-data:
"@

$dockerCompose | Out-File -FilePath "docker-compose-nominatim.yml" -Encoding UTF8

Write-Host "   ✓ Arquivo criado: docker-compose-nominatim.yml" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PRÓXIMOS PASSOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n1. Inicie o Nominatim (vai baixar $size e importar):" -ForegroundColor Yellow
Write-Host "   docker-compose -f docker-compose-nominatim.yml up -d" -ForegroundColor White
Write-Host "`n2. Acompanhe a importação (pode levar 30min-2h):" -ForegroundColor Yellow
Write-Host "   docker logs -f nominatim-local" -ForegroundColor White
Write-Host "`n3. Teste quando terminar:" -ForegroundColor Yellow
Write-Host "   http://localhost:8080/reverse?lat=-23.5505&lon=-46.6333&format=json" -ForegroundColor White
Write-Host "`n4. Configure seu servidor para usar:" -ForegroundColor Yellow
Write-Host "   Provider: openstreetmap" -ForegroundColor White
Write-Host "   osmServer: http://localhost:8080" -ForegroundColor White
Write-Host "`n========================================`n" -ForegroundColor Cyan

Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Yellow
Write-Host "   - A primeira importação demora (download + processamento)" -ForegroundColor Gray
Write-Host "   - Depois disso, terá geocoding ILIMITADO local!" -ForegroundColor Gray
Write-Host "   - Sem limites de requisições" -ForegroundColor Gray
Write-Host "   - Sem custos" -ForegroundColor Gray
Write-Host "`nDeseja iniciar agora? (S/N)" -ForegroundColor Cyan
$iniciar = Read-Host

if ($iniciar -eq "S" -or $iniciar -eq "s") {
    Write-Host "`nIniciando Nominatim..." -ForegroundColor Green
    docker-compose -f docker-compose-nominatim.yml up -d
    Write-Host "`nAcompanhe os logs em outra janela com:" -ForegroundColor Yellow
    Write-Host "docker logs -f nominatim-local`n" -ForegroundColor White
}
