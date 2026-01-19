@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    ETAPA 4: CONFIGURAR CLOUDFLARE TUNNEL
echo ═══════════════════════════════════════════════════════════
echo.

if exist "%USERPROFILE%\.cloudflared\8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json" (
    echo ✓ Credenciais do tunnel já configuradas
    echo.
    echo Pressione qualquer tecla para continuar...
    pause >nul
    exit /b 0
)

echo ⚠️  CREDENCIAIS NÃO ENCONTRADAS!
echo.
echo Você tem 2 opções:
echo.
echo [1] Copiar pasta .cloudflared do PC antigo (RECOMENDADO)
echo [2] Continuar e configurar depois
echo.
set /p opcao="Escolha (1 ou 2): "

if "%opcao%"=="1" (
    echo.
    echo ═══════════════════════════════════════════════════════════
    echo    COPIE A PASTA DO PC ANTIGO:
    echo ═══════════════════════════════════════════════════════════
    echo.
    echo DE:   C:\Users\Herbert\.cloudflared\
    echo PARA: C:\Users\%USERNAME%\.cloudflared\
    echo.
    echo Arquivos necessários:
    echo    ✓ cert.pem
    echo    ✓ 8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json
    echo    ✓ config.yml
    echo.
    echo.
    echo Você JÁ copiou a pasta? (S/N)
    set /p copiou=
    
    if /i "%copiou%"=="S" (
        if exist "%USERPROFILE%\.cloudflared\8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json" (
            echo.
            echo ✅ Credenciais encontradas!
            echo.
        ) else (
            echo.
            echo ✗ Arquivo não encontrado!
            echo   Copie a pasta corretamente e execute novamente.
            echo.
            echo Pressione qualquer tecla para sair...
            pause >nul
            exit /b 1
        )
    ) else (
        echo.
        echo Copie a pasta e execute este script novamente.
        echo.
        echo Pressione qualquer tecla para sair...
        pause >nul
        exit /b 1
    )
)

echo.
echo ═══════════════════════════════════════════════════════════
echo    ✅ CONFIGURAÇÃO CONCLUÍDA
echo ═══════════════════════════════════════════════════════════
echo.
echo Próximo passo: ETAPA5_DOCKER.bat
echo.
echo Pressione qualquer tecla para continuar...
pause >nul
