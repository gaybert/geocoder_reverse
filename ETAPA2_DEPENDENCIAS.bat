@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    ETAPA 2: INSTALANDO DEPENDÊNCIAS NPM
echo ═══════════════════════════════════════════════════════════
echo.

cd /d "%~dp0"

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Node.js não encontrado!
    echo   Execute primeiro: ETAPA1_NODEJS.bat
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

echo ✓ Node.js encontrado
node --version
echo.

echo Instalando pacotes NPM...
echo (Pode demorar alguns minutos)
echo.
call npm install

if %errorlevel% neq 0 (
    echo.
    echo ✗ ERRO ao instalar dependências!
    echo   Verifique sua conexão com internet.
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ DEPENDÊNCIAS INSTALADAS COM SUCESSO!
echo ═══════════════════════════════════════════════════════════
echo.
echo Próximo passo: ETAPA3_CLOUDFLARED.bat
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
