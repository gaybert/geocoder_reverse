@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    🔐 CONFIGURAR CLOUDFLARE TUNNEL - NOVO PC
echo ═══════════════════════════════════════════════════════════
echo.
echo Este script vai configurar o Cloudflare Tunnel neste PC.
echo.
echo Você tem 2 opções:
echo.
echo [1] Copiar credenciais do PC antigo (RECOMENDADO)
echo [2] Fazer novo login e reconfigurar
echo.
set /p opcao="Escolha (1 ou 2): "

if "%opcao%"=="1" goto COPIAR
if "%opcao%"=="2" goto LOGIN
echo Opção inválida!
pause
exit

:COPIAR
echo.
echo ═══════════════════════════════════════════════════════════
echo    📋 COPIAR CREDENCIAIS DO PC ANTIGO
echo ═══════════════════════════════════════════════════════════
echo.
echo No PC ANTIGO, copie toda a pasta:
echo    C:\Users\SEU_USUARIO\.cloudflared\
echo.
echo Cole neste PC em:
echo    C:\Users\%USERNAME%\.cloudflared\
echo.
echo Arquivos necessários:
echo    ✓ cert.pem
echo    ✓ 8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json
echo    ✓ config.yml
echo.
echo.
echo Você já copiou a pasta? (S/N)
set /p copiou=
if /i "%copiou%"=="S" goto VERIFICAR
echo.
echo Copie a pasta e execute este script novamente.
pause
exit

:VERIFICAR
echo.
echo Verificando arquivos...
if exist "%USERPROFILE%\.cloudflared\cert.pem" (
    echo ✓ cert.pem encontrado
) else (
    echo ✗ cert.pem NÃO encontrado!
    goto ERRO
)

if exist "%USERPROFILE%\.cloudflared\8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json" (
    echo ✓ Credenciais encontradas
) else (
    echo ✗ Credenciais NÃO encontradas!
    goto ERRO
)

if exist "%USERPROFILE%\.cloudflared\config.yml" (
    echo ✓ config.yml encontrado
) else (
    echo ✗ config.yml NÃO encontrado!
    goto ERRO
)

echo.
echo ✅ Tudo OK! Testando tunnel...
cloudflared tunnel run geocoder-mt
pause
exit

:LOGIN
echo.
echo ═══════════════════════════════════════════════════════════
echo    🔐 FAZER NOVO LOGIN
echo ═══════════════════════════════════════════════════════════
echo.
echo PASSO 1: Login no Cloudflare
echo.
pause
cloudflared tunnel login
echo.

echo PASSO 2: Baixando informações do tunnel existente
echo.
cloudflared tunnel list
echo.

echo PASSO 3: Criando arquivo config.yml
echo.
if not exist "%USERPROFILE%\.cloudflared" mkdir "%USERPROFILE%\.cloudflared"

echo tunnel: 8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9 > "%USERPROFILE%\.cloudflared\config.yml"
echo credentials-file: %USERPROFILE%\.cloudflared\8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json >> "%USERPROFILE%\.cloudflared\config.yml"
echo. >> "%USERPROFILE%\.cloudflared\config.yml"
echo ingress: >> "%USERPROFILE%\.cloudflared\config.yml"
echo   - hostname: geocoder.urbanmt.com.br >> "%USERPROFILE%\.cloudflared\config.yml"
echo     service: http://localhost:3002 >> "%USERPROFILE%\.cloudflared\config.yml"
echo   - service: http_status:404 >> "%USERPROFILE%\.cloudflared\config.yml"

echo.
echo PASSO 4: Baixando credenciais do tunnel
echo.
cloudflared tunnel token 8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9

echo.
echo ⚠️  Se o comando acima falhar, você precisa copiar manualmente
echo     o arquivo de credenciais do PC antigo.
echo.
pause
exit

:ERRO
echo.
echo ═══════════════════════════════════════════════════════════
echo    ✗ ERRO - Arquivos não encontrados
echo ═══════════════════════════════════════════════════════════
echo.
echo Copie TODA a pasta do PC antigo:
echo.
echo DE:   C:\Users\Herbert\.cloudflared\
echo PARA: C:\Users\%USERNAME%\.cloudflared\
echo.
echo Ou escolha a opção 2 (fazer novo login)
echo.
pause
exit
