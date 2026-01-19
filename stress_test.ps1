# Stress Test - Teste de limites de requisições
param(
    [int]$TotalRequests = 20,
    [int]$ConcurrentRequests = 5,
    [string]$Url = "http://localhost:3002/api/search_reverse"
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTE DE STRESS - $TotalRequests REQUISIÇÕES" -ForegroundColor Cyan
Write-Host "Concorrência: $ConcurrentRequests requisições simultâneas" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$coords = @(
    @{lat=-23.5505; lon=-46.6333},
    @{lat=40.7128; lon=-74.0060},
    @{lat=51.5074; lon=-0.1278},
    @{lat=48.8566; lon=2.3522},
    @{lat=-22.9068; lon=-43.1729}
)

$startTime = Get-Date
$results = @()
$successCount = 0
$errorCount = 0
$rateLimitErrors = 0

# Função para fazer requisição
function Invoke-GeoRequest {
    param($index, $coord)
    
    $reqStart = Get-Date
    $uri = "$Url`?latitude=$($coord.lat)&longitude=$($coord.lon)&provider=openstreetmap"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Method GET -TimeoutSec 30 -ErrorAction Stop
        $reqEnd = Get-Date
        $duration = ($reqEnd - $reqStart).TotalMilliseconds
        
        return @{
            Success = $true
            Index = $index
            Duration = $duration
            StatusCode = 200
        }
    } catch {
        $reqEnd = Get-Date
        $duration = ($reqEnd - $reqStart).TotalMilliseconds
        $errorMsg = $_.Exception.Message
        $isRateLimit = $errorMsg -match "429|rate|limit|too many"
        
        return @{
            Success = $false
            Index = $index
            Duration = $duration
            Error = $errorMsg
            IsRateLimit = $isRateLimit
        }
    }
}

# Executa requisições em lotes
$batchSize = $ConcurrentRequests
for ($i = 0; $i -lt $TotalRequests; $i += $batchSize) {
    $jobs = @()
    $batchEnd = [Math]::Min($i + $batchSize, $TotalRequests)
    
    Write-Host "Lote $([Math]::Floor($i/$batchSize) + 1): requisições $($i+1)-$batchEnd" -ForegroundColor Yellow
    
    for ($j = $i; $j -lt $batchEnd; $j++) {
        $coord = $coords[$j % $coords.Count]
        $job = Start-Job -ScriptBlock ${function:Invoke-GeoRequest} -ArgumentList ($j + 1), $coord
        $jobs += $job
    }
    
    # Aguarda lote completar
    $batchResults = $jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job
    
    foreach ($result in $batchResults) {
        $results += $result
        if ($result.Success) {
            $successCount++
            Write-Host "  [$($result.Index)] ✓ $([math]::Round($result.Duration, 0))ms" -ForegroundColor Green
        } else {
            $errorCount++
            if ($result.IsRateLimit) {
                $rateLimitErrors++
                Write-Host "  [$($result.Index)] ⚠ RATE LIMIT!" -ForegroundColor Red
            } else {
                Write-Host "  [$($result.Index)] ✗ Erro" -ForegroundColor Red
            }
        }
    }
    
    # Pequeno delay entre lotes
    if ($i + $batchSize -lt $TotalRequests) {
        Start-Sleep -Milliseconds 500
    }
}

$endTime = Get-Date
$totalDuration = ($endTime - $startTime).TotalSeconds

# Calcula estatísticas
$successResults = $results | Where-Object { $_.Success }
if ($successResults.Count -gt 0) {
    $avgDuration = ($successResults.Duration | Measure-Object -Average).Average
    $minDuration = ($successResults.Duration | Measure-Object -Minimum).Minimum
    $maxDuration = ($successResults.Duration | Measure-Object -Maximum).Maximum
} else {
    $avgDuration = 0
    $minDuration = 0
    $maxDuration = 0
}

$requestsPerSecond = $TotalRequests / $totalDuration

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESULTADOS DO TESTE DE STRESS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total de requisições: $TotalRequests"
Write-Host "Sucesso: $successCount ($([math]::Round($successCount/$TotalRequests*100, 1))%)" -ForegroundColor Green
Write-Host "Erros: $errorCount ($([math]::Round($errorCount/$TotalRequests*100, 1))%)" -ForegroundColor $(if($errorCount -gt 0){"Red"}else{"Green"})
Write-Host "Rate Limit: $rateLimitErrors" -ForegroundColor $(if($rateLimitErrors -gt 0){"Red"}else{"Green"})
Write-Host "`nTempo total: $([math]::Round($totalDuration, 2))s"
Write-Host "Requisições/segundo: $([math]::Round($requestsPerSecond, 2))"
Write-Host "`nLatência:"
Write-Host "  Média: $([math]::Round($avgDuration, 0))ms"
Write-Host "  Mínima: $([math]::Round($minDuration, 0))ms"
Write-Host "  Máxima: $([math]::Round($maxDuration, 0))ms"

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "LIMITES IDENTIFICADOS" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow

if ($rateLimitErrors -gt 0) {
    Write-Host "⚠️  OpenStreetMap está limitando requisições!" -ForegroundColor Red
    Write-Host "    Recomendado: máximo 1 req/segundo" -ForegroundColor Yellow
} else {
    Write-Host "✅ Nenhum rate limit detectado neste teste" -ForegroundColor Green
    Write-Host "    Mas lembre-se: OSM recomenda ~1 req/s" -ForegroundColor Yellow
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
