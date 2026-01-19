# Load Test Script - 10 requisições simultâneas
$url = "http://localhost:3002/api/search_reverse"
$totalRequests = 10

# Coordenadas de teste variadas
$coordinates = @(
    @{lat=-23.5505; lon=-46.6333; name="São Paulo"},
    @{lat=40.7128; lon=-74.0060; name="Nova York"},
    @{lat=51.5074; lon=-0.1278; name="Londres"},
    @{lat=48.8566; lon=2.3522; name="Paris"},
    @{lat=-22.9068; lon=-43.1729; name="Rio de Janeiro"},
    @{lat=35.6762; lon=139.6503; name="Tóquio"},
    @{lat=-33.8688; lon=151.2093; name="Sydney"},
    @{lat=55.7558; lon=37.6173; name="Moscou"},
    @{lat=39.9042; lon=116.4074; name="Pequim"},
    @{lat=-34.6037; lon=-58.3816; name="Buenos Aires"}
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "TESTE DE CARGA - 10 REQUISIÇÕES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Captura uso inicial de CPU e memória do processo node
$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $initialCpu = ($nodeProcesses | Measure-Object CPU -Sum).Sum
    $initialMemory = ($nodeProcesses | Measure-Object WorkingSet64 -Sum).Sum / 1MB
    Write-Host "CPU Inicial (acumulado): $([math]::Round($initialCpu, 2))s" -ForegroundColor Yellow
    Write-Host "Memória Inicial: $([math]::Round($initialMemory, 2)) MB`n" -ForegroundColor Yellow
}

# Array para armazenar jobs
$jobs = @()
$startTime = Get-Date

# Inicia requisições em paralelo
for ($i = 0; $i -lt $totalRequests; $i++) {
    $coord = $coordinates[$i]
    $uri = "$url`?latitude=$($coord.lat)&longitude=$($coord.lon)&provider=openstreetmap"
    
    $job = Start-Job -ScriptBlock {
        param($uri, $name, $index)
        $start = Get-Date
        try {
            $response = Invoke-RestMethod -Uri $uri -Method GET -ErrorAction Stop
            $end = Get-Date
            $duration = ($end - $start).TotalMilliseconds
            
            return @{
                Success = $true
                Index = $index
                Name = $name
                Duration = $duration
                City = $response.results[0].city
            }
        } catch {
            $end = Get-Date
            $duration = ($end - $start).TotalMilliseconds
            return @{
                Success = $false
                Index = $index
                Name = $name
                Duration = $duration
                Error = $_.Exception.Message
            }
        }
    } -ArgumentList $uri, $coord.name, ($i + 1)
    
    $jobs += $job
}

Write-Host "Aguardando conclusão de $totalRequests requisições paralelas..." -ForegroundColor Cyan

# Aguarda todas as requisições
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

$endTime = Get-Date
$totalDuration = ($endTime - $startTime).TotalSeconds

# Captura uso final de CPU e memória
Start-Sleep -Milliseconds 500
$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $finalCpu = ($nodeProcesses | Measure-Object CPU -Sum).Sum
    $finalMemory = ($nodeProcesses | Measure-Object WorkingSet64 -Sum).Sum / 1MB
}

# Exibe resultados
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "RESULTADOS" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

$successCount = ($results | Where-Object { $_.Success }).Count
$failCount = $totalRequests - $successCount

foreach ($result in $results | Sort-Object Index) {
    if ($result.Success) {
        Write-Host "[$($result.Index)] $($result.Name) → $($result.City) - $([math]::Round($result.Duration, 0))ms" -ForegroundColor Green
    } else {
        Write-Host "[$($result.Index)] $($result.Name) - ERRO: $($result.Error)" -ForegroundColor Red
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "ESTATÍSTICAS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$durations = ($results | Where-Object { $_.Success }).Duration
$avgDuration = ($durations | Measure-Object -Average).Average
$minDuration = ($durations | Measure-Object -Minimum).Minimum
$maxDuration = ($durations | Measure-Object -Maximum).Maximum

Write-Host "Total de requisições: $totalRequests"
Write-Host "Sucesso: $successCount | Falhas: $failCount"
Write-Host "Tempo total: $([math]::Round($totalDuration, 2))s"
Write-Host "Tempo médio por requisição: $([math]::Round($avgDuration, 0))ms"
Write-Host "Tempo mínimo: $([math]::Round($minDuration, 0))ms"
Write-Host "Tempo máximo: $([math]::Round($maxDuration, 0))ms"

if ($nodeProcesses) {
    $cpuDiff = $finalCpu - $initialCpu
    $memoryDiff = $finalMemory - $initialMemory
    
    Write-Host "`n========================================" -ForegroundColor Yellow
    Write-Host "USO DE RECURSOS (Node.js)" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "CPU Final (acumulado): $([math]::Round($finalCpu, 2))s"
    Write-Host "CPU usado no teste: $([math]::Round($cpuDiff, 2))s"
    Write-Host "Memória Final: $([math]::Round($finalMemory, 2)) MB"
    Write-Host "Memória variação: $([math]::Round($memoryDiff, 2)) MB"
    
    Write-Host "`nProcessos Node ativos:" -ForegroundColor Yellow
    $nodeProcesses | Format-Table Id, 
        @{Label="CPU(s)"; Expression={[math]::Round($_.CPU, 2)}},
        @{Label="Memória(MB)"; Expression={[math]::Round($_.WorkingSet64/1MB, 2)}},
        @{Label="PID"; Expression={$_.Id}} -AutoSize
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
