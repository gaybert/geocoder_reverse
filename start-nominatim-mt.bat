@echo off
chcp 65001 >nul
title Nominatim Mato Grosso - Setup

echo.
echo ========================================
echo   NOMINATIM LOCAL - Mato Grosso
echo   Geocoding ILIMITADO e GRATUITO
echo ========================================
echo.

echo Verificando Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker não instalado!
    echo.
    echo Instale Docker Desktop:
    echo https://www.docker.com/products/docker-desktop
    pause
    exit
)
echo ✓ Docker instalado
echo.

echo ========================================
echo   INFORMAÇÕES
echo ========================================
echo.
echo Região: Mato Grosso, Brasil
echo Tamanho: ~2GB (Brasil inteiro, mas indexa rápido)
echo Tempo: 30-60 minutos (primeira vez)
echo Porta: 8080
echo.
echo ⚠️  O Docker vai baixar dados do Brasil inteiro,
echo     mas o foco será no Mato Grosso.
echo.
echo ========================================
echo.

set /p continuar="Deseja continuar? (S/N): "
if /i not "%continuar%"=="S" exit

echo.
echo Iniciando Nominatim...
echo.
docker-compose -f docker-compose-nominatim-mt.yml up -d

echo.
echo ========================================
echo   INICIADO!
echo ========================================
echo.
echo O Nominatim está baixando e importando os dados.
echo Isso pode levar 30-60 minutos.
echo.
echo Acompanhe o progresso:
echo   docker logs -f nominatim-mato-grosso
echo.
echo Quando terminar, teste em:
echo   http://localhost:8080/reverse?lat=-15.5989&lon=-56.0949^&format=json
echo   (Cuiabá, MT)
echo.
echo Para parar:
echo   docker-compose -f docker-compose-nominatim-mt.yml down
echo.
echo ========================================
echo.

set /p logs="Deseja ver os logs agora? (S/N): "
if /i "%logs%"=="S" docker logs -f nominatim-mato-grosso

pause
