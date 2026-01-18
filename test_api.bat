@echo off
REM Test script for the Geocoder API
REM Compatible with n8n HTTP Request node

echo.
echo ======================================================================
echo Testing Geocoder API
echo ======================================================================
echo.

REM Test 1: Health check
echo [1] Testing Health Check...
curl -s http://localhost:3000/health | more
echo.
echo.

REM Test 2: Get available providers
echo [2] Getting Available Providers...
curl -s http://localhost:3000/api/providers | more
echo.
echo.

REM Test 3: Reverse geocoding with GET - Eiffel Tower
echo [3] Reverse Geocoding - Eiffel Tower (GET)...
curl -s "http://localhost:3000/api/search_reverse?latitude=48.8584&longitude=2.2945&provider=openstreetmap" | more
echo.
echo.

REM Test 4: Reverse geocoding with GET - Statue of Liberty
echo [4] Reverse Geocoding - Statue of Liberty (GET)...
curl -s "http://localhost:3000/api/search_reverse?lat=40.6892&lng=-74.0445&provider=openstreetmap" | more
echo.
echo.

REM Test 5: Reverse geocoding with POST
echo [5] Reverse Geocoding - Cristo Redentor (POST)...
curl -s -X POST http://localhost:3000/api/search_reverse ^
  -H "Content-Type: application/json" ^
  -d "{ \"latitude\": -22.9519, \"longitude\": -43.2105, \"provider\": \"openstreetmap\" }" | more
echo.
echo.

REM Test 6: Forward geocoding
echo [6] Forward Geocoding - Search for address (POST)...
curl -s -X POST http://localhost:3000/api/search ^
  -H "Content-Type: application/json" ^
  -d "{ \"address\": \"29 champs elysee paris\", \"provider\": \"openstreetmap\" }" | more
echo.
echo.

REM Test 7: Error handling - Invalid coordinates
echo [7] Testing Error Handling - Invalid Coordinates...
curl -s "http://localhost:3000/api/search_reverse?latitude=invalid&longitude=2.2945" | more
echo.
echo.

echo ======================================================================
echo Tests completed!
echo ======================================================================
