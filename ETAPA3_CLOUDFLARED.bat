@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    ETAPA 3: INSTALANDO CLOUDFLARED
echo ═══════════════════════════════════════════════════════════
echo.

where cloudflared >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Cloudflared já instalado
    cloudflared --version
    echo.
    echo Pressione qualquer tecla para continuar...
    pause >nul
    exit /b 0
)

echo Cloudflared não encontrado. Iniciando instalação...
echo.
echo 📥 Baixando Cloudflared...
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi' -OutFile '%TEMP%\cloudflared.msi'"

if %errorlevel% neq 0 (
    echo.
    echo ✗ ERRO ao baixar Cloudflared!
    echo   Verifique sua conexão com internet.
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

echo.
echo 📦 Instalando Cloudflared...
msiexec /i "%TEMP%\cloudflared.msi" /quiet /norestart

echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ CLOUDFLARED INSTALADO COM SUCESSO!
echo ═══════════════════════════════════════════════════════════
echo.
echo Próximo passo: ETAPA4_CONFIGURAR_TUNNEL.bat
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
