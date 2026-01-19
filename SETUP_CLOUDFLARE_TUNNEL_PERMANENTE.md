# 🌐 CLOUDFLARE TUNNEL PERMANENTE
## geocoder.urbanmt.com.br → Seu PC (porta 3002)

---

## 📋 PASSO 1: Instalar Cloudflared (Windows)

Baixe e instale o Cloudflared:
https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi

Ou via PowerShell:
```powershell
# Baixar
Invoke-WebRequest -Uri "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi" -OutFile "$env:TEMP\cloudflared.msi"

# Instalar
Start-Process msiexec.exe -Wait -ArgumentList "/i $env:TEMP\cloudflared.msi /quiet"
```

---

## 🔐 PASSO 2: Fazer Login no Cloudflare

Execute no PowerShell:
```powershell
cloudflared tunnel login
```

- Vai abrir o navegador
- Faça login no Cloudflare
- Selecione o domínio **urbanmt.com.br**
- Autorize

---

## 🛠️ PASSO 3: Criar Tunnel Nomeado

Execute no PowerShell:
```powershell
cloudflared tunnel create geocoder-mt
```

Isso vai criar:
- Tunnel ID (UUID)
- Arquivo de credenciais em: `C:\Users\Herbert\.cloudflared\<UUID>.json`

**ANOTE O TUNNEL ID** que aparece! (ex: a1b2c3d4-...)

---

## ⚙️ PASSO 4: Criar Arquivo de Configuração

Crie o arquivo: `C:\Users\Herbert\.cloudflared\config.yml`

```yaml
tunnel: <TUNNEL-ID-AQUI>
credentials-file: C:\Users\Herbert\.cloudflared\<TUNNEL-ID-AQUI>.json

ingress:
  - hostname: geocoder.urbanmt.com.br
    service: http://localhost:3002
  - service: http_status:404
```

**Substitua `<TUNNEL-ID-AQUI>` pelo ID que anotou!**

---

## 🌐 PASSO 5: Configurar DNS no Cloudflare

Execute no PowerShell (substitua o TUNNEL-ID):
```powershell
cloudflared tunnel route dns <TUNNEL-ID> geocoder.urbanmt.com.br
```

Ou manualmente no Cloudflare Dashboard:
1. Acesse: https://dash.cloudflare.com
2. Selecione **urbanmt.com.br**
3. Vá em **DNS** → **Records**
4. **EDITE** o registro `geocoder`:
   - **Tipo:** CNAME
   - **Nome:** geocoder
   - **Destino:** `<TUNNEL-ID>.cfargotunnel.com`
   - **Proxy:** Ativado (nuvem laranja)
   - **TTL:** Auto

---

## 🚀 PASSO 6: Iniciar o Tunnel

Execute no PowerShell:
```powershell
cloudflared tunnel run geocoder-mt
```

Ou deixe rodando como serviço (recomendado):
```powershell
cloudflared service install
```

---

## ✅ PASSO 7: Testar

Teste a URL:
```
https://geocoder.urbanmt.com.br/health
https://geocoder.urbanmt.com.br/api/search_reverse?latitude=-10.166061&longitude=-54.935305
```

---

## 🔄 INICIAR AUTOMATICAMENTE

Crie o arquivo: `start_geocoder_permanent.bat`

```batch
@echo off
chcp 65001 >nul
cls
echo.
echo ═══════════════════════════════════════════════════════════
echo    🌍 GEOCODER - TUNNEL PERMANENTE
echo    https://geocoder.urbanmt.com.br
echo ═══════════════════════════════════════════════════════════
echo.

echo [1/3] Limpando processos antigos...
taskkill /F /IM node.exe 2>nul
taskkill /F /IM cloudflared.exe 2>nul
timeout /t 2 /nobreak >nul
echo       ✓ Processos limpos
echo.

echo [2/3] Iniciando servidor na porta 3002...
start "SERVIDOR GEOCODER" cmd /k "cd /d %~dp0 && color 0A && echo. && echo  🚀 GEOCODER SERVER && echo     https://geocoder.urbanmt.com.br && echo. && npm start"
timeout /t 6 /nobreak >nul
echo       ✓ Servidor iniciado
echo.

echo [3/3] Iniciando Cloudflare Tunnel...
start "CLOUDFLARE TUNNEL" cmd /k "cd /d %~dp0 && color 0B && echo. && echo  ☁️  CLOUDFLARE TUNNEL && echo     URL FIXA: https://geocoder.urbanmt.com.br && echo. && cloudflared tunnel run geocoder-mt"
timeout /t 5 /nobreak >nul
echo       ✓ Tunnel iniciado
echo.

echo ═══════════════════════════════════════════════════════════
echo    ✅ TUDO PRONTO!
echo ═══════════════════════════════════════════════════════════
echo.
echo 🌐 URL PERMANENTE:
echo    https://geocoder.urbanmt.com.br
echo.
echo 📊 Endpoints:
echo    /health
echo    /api/search_reverse?latitude=LAT&longitude=LON
echo.
pause
```

---

## 📱 CONFIGURAR NO N8N

Use a URL fixa:
```
https://geocoder.urbanmt.com.br/api/search_reverse
```

**Nunca mais vai precisar trocar a URL!** 🎉

---

## 🛑 PARAR TUDO

```powershell
# Parar processos
taskkill /F /IM node.exe
taskkill /F /IM cloudflared.exe

# Ou se instalou como serviço
cloudflared service uninstall
```

---

## 🆘 TROUBLESHOOTING

### Tunnel não conecta
```powershell
# Ver status
cloudflared tunnel info geocoder-mt

# Ver logs
cloudflared tunnel run geocoder-mt --loglevel debug
```

### DNS não resolve
- Aguarde 2-5 minutos (propagação DNS)
- Verifique: https://dnschecker.org/#CNAME/geocoder.urbanmt.com.br

### Erro 502 Bad Gateway
- Verifique se o servidor está rodando: http://localhost:3002/health
- Reinicie o tunnel

---

## 🎯 VANTAGENS

✅ URL fixa permanente: `geocoder.urbanmt.com.br`  
✅ HTTPS automático (certificado Cloudflare)  
✅ Não precisa trocar URL no n8n nunca mais  
✅ Proteção DDoS do Cloudflare  
✅ Cache do Cloudflare (mais rápido)  
✅ Gratuito!  

---

**Quer que eu execute os comandos agora para configurar tudo?** 🚀
