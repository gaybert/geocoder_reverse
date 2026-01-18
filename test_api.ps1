# Test script for the Geocoder API
# Compatible with n8n HTTP Request node

$apiUrl = "http://localhost:3000"

Write-Host "======================================================================"
Write-Host "Testing Geocoder API"
Write-Host "======================================================================"
Write-Host ""

# Test 1: Health check
Write-Host "[1] Testing Health Check..." -ForegroundColor Green
$response = Invoke-WebRequest -Uri "$apiUrl/health" -Method Get
Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
Write-Host ""
Write-Host ""

# Test 2: Get available providers
Write-Host "[2] Getting Available Providers..." -ForegroundColor Green
$response = Invoke-WebRequest -Uri "$apiUrl/api/providers" -Method Get
Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
Write-Host ""
Write-Host ""

# Test 3: Reverse geocoding - Eiffel Tower (GET)
Write-Host "[3] Reverse Geocoding - Eiffel Tower (GET)" -ForegroundColor Green
$response = Invoke-WebRequest -Uri "$apiUrl/api/search_reverse?latitude=48.8584&longitude=2.2945&provider=openstreetmap" -Method Get
Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
Write-Host ""
Write-Host ""

# Test 4: Reverse geocoding - Statue of Liberty (GET, alternate parameter names)
Write-Host "[4] Reverse Geocoding - Statue of Liberty (GET with lat/lng)" -ForegroundColor Green
$response = Invoke-WebRequest -Uri "$apiUrl/api/search_reverse?lat=40.6892&lng=-74.0445&provider=openstreetmap" -Method Get
Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
Write-Host ""
Write-Host ""

# Test 5: Reverse geocoding - Cristo Redentor (POST)
Write-Host "[5] Reverse Geocoding - Cristo Redentor (POST)" -ForegroundColor Green
$body = @{
    latitude = -22.9519
    longitude = -43.2105
    provider = "openstreetmap"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "$apiUrl/api/search_reverse" -Method Post -ContentType "application/json" -Body $body
Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
Write-Host ""
Write-Host ""

# Test 6: Reverse geocoding - Colosseum Rome (POST)
Write-Host "[6] Reverse Geocoding - Colosseum Rome (POST)" -ForegroundColor Green
$body = @{
    latitude = 41.8902
    longitude = 12.4924
    provider = "openstreetmap"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "$apiUrl/api/search_reverse" -Method Post -ContentType "application/json" -Body $body
Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
Write-Host ""
Write-Host ""

# Test 7: Forward geocoding - Search for address
Write-Host "[7] Forward Geocoding - Search for address (POST)" -ForegroundColor Green
$body = @{
    address = "29 champs elysee paris"
    provider = "openstreetmap"
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri "$apiUrl/api/search" -Method Post -ContentType "application/json" -Body $body
Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
Write-Host ""
Write-Host ""

# Test 8: Error handling - Invalid coordinates
Write-Host "[8] Testing Error Handling - Invalid Coordinates" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/api/search_reverse?latitude=invalid&longitude=2.2945" -Method Get
    Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
} catch {
    Write-Host ($_.Exception.Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10) -ForegroundColor Red
}
Write-Host ""
Write-Host ""

# Test 9: Error handling - Invalid provider
Write-Host "[9] Testing Error Handling - Invalid Provider" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/api/search_reverse?latitude=48.8584&longitude=2.2945&provider=invalid" -Method Get
    Write-Host ($response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10)
} catch {
    Write-Host ($_.Exception.Response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10) -ForegroundColor Red
}
Write-Host ""
Write-Host ""

Write-Host "======================================================================"
Write-Host "Tests completed!" -ForegroundColor Green
Write-Host "======================================================================"
