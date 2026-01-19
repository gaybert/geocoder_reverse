@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    ETAPA 1: INSTALANDO NODE.JS
echo ═══════════════════════════════════════════════════════════
echo.

where node >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Node.js já instalado
    node --version
    echo.
    echo Pressione qualquer tecla para continuar...
    pause >nul
    exit /b 0
)

echo Node.js não encontrado. Iniciando instalação...
echo.
echo 📥 Baixando Node.js LTS (v20.11.0)...
powershell -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi' -OutFile '%TEMP%\nodejs.msi'"

if %errorlevel% neq 0 (
    echo.
    echo ✗ ERRO ao baixar Node.js!
    echo   Verifique sua conexão com internet.
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

echo.
echo 📦 Instalando Node.js...
echo    (Pode demorar alguns minutos)
msiexec /i "%TEMP%\nodejs.msi" /quiet /norestart

echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ NODE.JS INSTALADO COM SUCESSO!
echo ═══════════════════════════════════════════════════════════
echo.
echo ⚠️  IMPORTANTE:
echo    Feche TODAS as janelas do terminal/cmd
echo    e execute o próximo script: ETAPA2_DEPENDENCIAS.bat
echo.
echo Pressione qualquer tecla para fechar...
pause >nul
