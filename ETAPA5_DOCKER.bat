@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    ETAPA 5: CONFIGURAR DOCKER E NOMINATIM
echo ═══════════════════════════════════════════════════════════
echo.

docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Docker não encontrado!
    echo.
    echo Por favor:
    echo 1. Instale Docker Desktop de: https://www.docker.com/products/docker-desktop
    echo 2. Execute este script novamente
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

echo ✓ Docker encontrado
docker --version
echo.

echo Verificando se Docker está rodando...
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Docker não está rodando!
    echo.
    echo Por favor:
    echo 1. Abra Docker Desktop
    echo 2. Aguarde iniciar completamente
    echo 3. Execute este script novamente
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

echo ✓ Docker está rodando
echo.

echo Verificando container Nominatim...
docker ps -a | findstr nominatim-mato-grosso >nul
if %errorlevel% equ 0 (
    echo ✓ Container Nominatim já existe
    docker start nominatim-mato-grosso 2>nul
    echo ✓ Container iniciado
) else (
    echo.
    echo Criando container Nominatim...
    echo ⚠️  ATENÇÃO: Primeira vez demora ~2 horas!
    echo    Dados: Brasil (~2GB)
    echo.
    echo Deseja criar o container agora? (S/N)
    set /p criar=
    
    if /i "%criar%"=="S" (
        echo.
        echo Criando container...
        docker run -d --name nominatim-mato-grosso -p 8080:8080 -e PBF_URL=https://download.geofabrik.de/south-america/brazil-latest.osm.pbf -e REPLICATION_URL=https://download.geofabrik.de/south-america/brazil-updates/ -e IMPORT_WIKIPEDIA=false -e NOMINATIM_PASSWORD=nominatim_mt_2026 -e IMPORT_STYLE=admin -v nominatim-data-mt:/var/lib/postgresql/14/main --shm-size=2g mediagis/nominatim:4.4
        
        if %errorlevel% equ 0 (
            echo.
            echo ✅ Container criado com sucesso!
            echo.
            echo Acompanhe a importação:
            echo    docker logs -f nominatim-mato-grosso
            echo.
        ) else (
            echo.
            echo ✗ Erro ao criar container!
            echo.
            echo Pressione qualquer tecla para sair...
            pause >nul
            exit /b 1
        )
    )
)

echo.
echo Criando arquivo .env...
if not exist "%~dp0.env" (
    echo PORT=3002 > "%~dp0.env"
    echo PROVIDER_DEFAULT=openstreetmap >> "%~dp0.env"
    echo OSM_SERVER=http://localhost:8080 >> "%~dp0.env"
    echo OSM_USER_AGENT=geocoder-mato-grosso >> "%~dp0.env"
    echo ✓ Arquivo .env criado
) else (
    echo ✓ Arquivo .env já existe
)

echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ DOCKER E NOMINATIM CONFIGURADOS!
echo ═══════════════════════════════════════════════════════════
echo.
echo ⚠️  Se criou o container agora, aguarde ~2 horas
echo    para a importação terminar.
echo.
echo Próximo passo (opcional): ETAPA6_SERVICO_WINDOWS.bat
echo Ou use: INICIAR.bat para testar
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
