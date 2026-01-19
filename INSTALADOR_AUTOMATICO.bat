@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════════════
echo    🚀 INSTALADOR AUTOMÁTICO - GEOCODER 24/7
echo    Desktop - Instalação Completa
echo ═══════════════════════════════════════════════════════════════════
echo.
echo Este script vai instalar TUDO automaticamente:
echo   ✓ Node.js e dependências
echo   ✓ Cloudflared
echo   ✓ Nominatim (Docker)
echo   ✓ Configurações
echo   ✓ Serviço Windows (24h)
echo.
echo ⚠️  IMPORTANTE: Execute como ADMINISTRADOR!
echo.
pause

set ERRO=0

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ETAPA 1: Verificando Node.js
echo ═══════════════════════════════════════════════════════════════════
echo.

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ⚠️  Node.js não encontrado!
    echo.
    echo 📥 Baixando Node.js LTS...
    powershell -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi' -OutFile '%TEMP%\nodejs.msi'"
    if %errorlevel% neq 0 (
        echo.
        echo ✗ ERRO ao baixar Node.js!
        echo   Verifique sua conexão com a internet.
        echo.
        set ERRO=1
        goto FIM_COM_ERRO
    )
    echo.
    echo 📦 Instalando Node.js...
    msiexec /i "%TEMP%\nodejs.msi" /quiet /norestart
    echo.
    echo ═══════════════════════════════════════════════════════════════════
    echo    ✅ Node.js INSTALADO COM SUCESSO!
    echo ═══════════════════════════════════════════════════════════════════
    echo.
    echo ⚠️  IMPORTANTE: Você precisa REINICIAR este script!
    echo.
    echo 1. Pressione qualquer tecla para fechar
    echo 2. Execute INSTALADOR_AUTOMATICO.bat novamente
    echo.
    echo O Node.js foi instalado, mas o PATH precisa ser recarregado.
    echo.
    echo Pressione qualquer tecla para fechar...
    pause >nul
    exit
) else (
    echo ✓ Node.js já instalado
    node --version
)

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ETAPA 2: Instalando dependências NPM
echo ═══════════════════════════════════════════════════════════════════
echo.

cd /d "%~dp0"
echo Instalando pacotes...
call npm install
if %errorlevel% neq 0 (
    echo.
    echo ✗ ERRO ao instalar dependências!
    echo.
    set ERRO=1
    goto FIM_COM_ERRO
)
echo ✓ Dependências instaladas

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ETAPA 3: Instalando Cloudflared
echo ═══════════════════════════════════════════════════════════════════
echo.

where cloudflared >nul 2>&1
if %errorlevel% neq 0 (
    echo 📥 Baixando Cloudflared...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi' -OutFile '%TEMP%\cloudflared.msi'"
    echo 📦 Instalando Cloudflared...
    msiexec /i "%TEMP%\cloudflared.msi" /quiet /norestart
    echo ✓ Cloudflared instalado
) else (
    echo ✓ Cloudflared já instalado
    cloudflared --version
)

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ETAPA 4: Configurando Cloudflare Tunnel
echo ═══════════════════════════════════════════════════════════════════
echo.

if not exist "%USERPROFILE%\.cloudflared\8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json" (
    echo.
    echo ⚠️  CREDENCIAIS DO TUNNEL NÃO ENCONTRADAS!
    echo.
    echo Você precisa copiar os arquivos do PC antigo:
    echo.
    echo DE:   C:\Users\Herbert\.cloudflared\
    echo PARA: C:\Users\%USERNAME%\.cloudflared\
    echo.
    echo Arquivos necessários:
    echo    ✓ cert.pem
    echo    ✓ 8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json
    echo    ✓ config.yml
    echo.
    echo Ou execute: CONFIGURAR_TUNNEL_NOVO_PC.bat
    echo.
    pause
    
    echo Tentando configurar automaticamente...
    if not exist "%USERPROFILE%\.cloudflared" mkdir "%USERPROFILE%\.cloudflared"
    
    if not exist "%USERPROFILE%\.cloudflared\cert.pem" (
        echo Fazendo login no Cloudflare...
        cloudflared tunnel login
    )
    
    if not exist "%USERPROFILE%\.cloudflared\config.yml" (
        echo Criando config.yml...
        (
            echo tunnel: 8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9
            echo credentials-file: %USERPROFILE%\.cloudflared\8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json
            echo.
            echo ingress:
            echo   - hostname: geocoder.urbanmt.com.br
            echo     service: http://localhost:3002
            echo   - service: http_status:404
        ) > "%USERPROFILE%\.cloudflared\config.yml"
    )
    
    echo.
    echo ⚠️  Você ainda precisa copiar o arquivo de credenciais:
    echo    8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json
    echo    do PC antigo para: %USERPROFILE%\.cloudflared\
    echo.
) else (
    echo ✓ Credenciais do tunnel encontradas
)

echo ✓ Cloudflare Tunnel configurado

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ETAPA 5: Configurando Nominatim (Docker)
echo ═══════════════════════════════════════════════════════════════════
echo.

docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ✗ ERRO: Docker não encontrado!
    echo   Instale o Docker Desktop e execute este script novamente.
    echo.
    set ERRO=1
    goto FIM_COM_ERRO
)

echo ✓ Docker encontrado
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ⚠️  ERRO: Docker não está rodando!
    echo   Inicie o Docker Desktop e aguarde...
    echo.
    set ERRO=1
    goto FIM_COM_ERRO
)

echo.
echo Verificando se Nominatim já existe...
docker ps -a | findstr nominatim-mato-grosso >nul
if %errorlevel% equ 0 (
    echo ✓ Nominatim já existe
    docker start nominatim-mato-grosso 2>nul
    echo ✓ Nominatim iniciado
) else (
    echo.
    echo 📥 Criando container Nominatim (demora ~2 horas na primeira vez)...
    echo    Dados: Brasil (~2GB)
    echo.
    docker run -d --name nominatim-mato-grosso -p 8080:8080 -e PBF_URL=https://download.geofabrik.de/south-america/brazil-latest.osm.pbf -e REPLICATION_URL=https://download.geofabrik.de/south-america/brazil-updates/ -e IMPORT_WIKIPEDIA=false -e NOMINATIM_PASSWORD=nominatim_mt_2026 -e IMPORT_STYLE=admin -v nominatim-data-mt:/var/lib/postgresql/14/main --shm-size=2g mediagis/nominatim:4.4
    echo.
    echo ✓ Container criado! Importação em andamento...
    echo.
    echo Você pode acompanhar com: docker logs -f nominatim-mato-grosso
    echo.
)

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ETAPA 6: Criando arquivo .env
echo ═══════════════════════════════════════════════════════════════════
echo.

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
echo ═══════════════════════════════════════════════════════════════════
echo    ETAPA 7: Instalando como Serviço Windows (24h)
echo ═══════════════════════════════════════════════════════════════════
echo.

where nssm >nul 2>&1
if %errorlevel% neq 0 (
    echo 📥 Baixando NSSM (gerenciador de serviços)...
    powershell -Command "Invoke-WebRequest -Uri 'https://nssm.cc/release/nssm-2.24.zip' -OutFile '%TEMP%\nssm.zip'; Expand-Archive -Path '%TEMP%\nssm.zip' -DestinationPath '%TEMP%\nssm' -Force; Copy-Item '%TEMP%\nssm\nssm-2.24\win64\nssm.exe' 'C:\Windows\System32\nssm.exe'"
    echo ✓ NSSM instalado
)

echo.
echo Instalando serviços...
echo.

rem Serviço do servidor Node.js
nssm stop GeocoderServer 2>nul
nssm remove GeocoderServer confirm 2>nul
nssm install GeocoderServer "C:\Program Files\nodejs\node.exe" "%~dp0index.js"
nssm set GeocoderServer AppDirectory "%~dp0"
nssm set GeocoderServer DisplayName "Geocoder Server - urbanmt.com.br"
nssm set GeocoderServer Description "Servidor de geocoding reverso com Nominatim"
nssm set GeocoderServer Start SERVICE_AUTO_START
nssm set GeocoderServer AppStdout "%~dp0logs\server.log"
nssm set GeocoderServer AppStderr "%~dp0logs\server-error.log"
nssm set GeocoderServer AppRotateFiles 1
nssm set GeocoderServer AppRotateBytes 10485760
echo ✓ Serviço GeocoderServer instalado

rem Serviço do Cloudflare Tunnel
nssm stop CloudflareTunnel 2>nul
nssm remove CloudflareTunnel confirm 2>nul
nssm install CloudflareTunnel "C:\Program Files\cloudflared\cloudflared.exe" "tunnel run geocoder-mt"
nssm set CloudflareTunnel DisplayName "Cloudflare Tunnel - geocoder.urbanmt.com.br"
nssm set CloudflareTunnel Description "Tunnel permanente para geocoder"
nssm set CloudflareTunnel Start SERVICE_AUTO_START
nssm set CloudflareTunnel AppStdout "%~dp0logs\tunnel.log"
nssm set CloudflareTunnel AppStderr "%~dp0logs\tunnel-error.log"
nssm set CloudflareTunnel AppRotateFiles 1
nssm set CloudflareTunnel AppRotateBytes 10485760
echo ✓ Serviço CloudflareTunnel instalado

rem Criar pasta de logs
if not exist "%~dp0logs" mkdir "%~dp0logs"

echo.
echo Iniciando serviços...
nssm start GeocoderServer
nssm start CloudflareTunnel
echo ✓ Serviços iniciados

echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!
echo ═══════════════════════════════════════════════════════════════════
echo.
echo 🌐 URL Permanente:
echo    https://geocoder.urbanmt.com.br
echo.
echo 📊 Status dos serviços:
echo.
sc query GeocoderServer | findstr "STATE"
sc query CloudflareTunnel | findstr "STATE"
echo.
echo 💡 Comandos úteis:
echo    Ver logs servidor:  type logs\server.log
echo    Ver logs tunnel:    type logs\tunnel.log
echo    Parar serviços:     nssm stop GeocoderServer ^&^& nssm stop CloudflareTunnel
echo    Iniciar serviços:   nssm start GeocoderServer ^&^& nssm start CloudflareTunnel
echo    Remover serviços:   execute DESINSTALAR_SERVICOS.bat
echo.
echo 🔄 Os serviços iniciam automaticamente com o Windows!
echo.
echo ⏳ Aguarde ~2 horas para o Nominatim terminar a importação (primeira vez)
echo    Acompanhe: docker logs -f nominatim-mato-grosso
echo.
goto FIM_SUCESSO

:FIM_COM_ERRO
echo.
echo ═══════════════════════════════════════════════════════════════════
echo    ❌ INSTALAÇÃO INTERROMPIDA - ERRO ENCONTRADO
echo ═══════════════════════════════════════════════════════════════════
echo.
echo ⚠️  A instalação foi interrompida devido a erros.
echo.
echo 🔍 Verifique as mensagens acima para identificar o problema.
echo.
echo 📋 Problemas comuns:
echo    - Docker não instalado: Instale Docker Desktop
echo    - Docker não iniciado: Abra Docker Desktop
echo    - Dependências NPM: Verifique conexão de internet
echo    - Credenciais Cloudflare: Execute CONFIGURAR_TUNNEL_NOVO_PC.bat
echo.
echo 💡 Após resolver o problema, execute este script novamente.
echo.
echo Pressione qualquer tecla para fechar...
pause >nul
exit

:FIM_SUCESSO
echo.
echo Pressione qualquer tecla para fechar...
pause >nul
