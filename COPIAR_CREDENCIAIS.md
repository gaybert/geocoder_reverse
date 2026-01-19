# 🔐 COPIAR CREDENCIAIS PARA NOVO PC

## ❌ ERRO: "tunnel credentials file not found"

Este erro aparece porque as credenciais do Cloudflare Tunnel não foram copiadas para o novo PC.

---

## ✅ SOLUÇÃO RÁPIDA

### No PC ANTIGO:

1. Copie a pasta:
```
C:\Users\Herbert\.cloudflared\
```

### No PC NOVO (Desktop):

2. Cole em:
```
C:\Users\SEU_USUARIO\.cloudflared\
```

---

## 📁 Arquivos necessários:

Dentro da pasta `.cloudflared` você precisa de:

- ✅ `cert.pem` (certificado de autenticação)
- ✅ `8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json` (credenciais do tunnel)
- ✅ `config.yml` (configuração)

---

## 🛠️ SCRIPT AUTOMÁTICO

Execute no PC NOVO:
```
CONFIGURAR_TUNNEL_NOVO_PC.bat
```

Este script vai te guiar para:
1. Copiar credenciais do PC antigo OU
2. Fazer novo login (menos recomendado)

---

## ✋ ALTERNATIVA (Manual)

Se não conseguir copiar, no PC NOVO:

1. Fazer login:
```bash
cloudflared tunnel login
```

2. Criar config.yml em `C:\Users\SEU_USUARIO\.cloudflared\config.yml`:
```yaml
tunnel: 8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9
credentials-file: C:\Users\SEU_USUARIO\.cloudflared\8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json

ingress:
  - hostname: geocoder.urbanmt.com.br
    service: http://localhost:3002
  - service: http_status:404
```

3. Mas você ainda precisa do arquivo `8d7a8fc3-93f4-4f92-86b0-1f43e5ec6be9.json` do PC antigo!

---

## 🧪 TESTAR

Depois de copiar, teste:
```bash
cloudflared tunnel run geocoder-mt
```

Se funcionar, você verá:
```
Registered tunnel connection
```

---

## 🚀 DEPOIS DE COPIAR

Execute normalmente:
```
INICIAR.bat
```

Ou:
```
INSTALADOR_AUTOMATICO.bat
```

---

## ❓ AINDA COM PROBLEMA?

Execute:
```
CONFIGURAR_TUNNEL_NOVO_PC.bat
```

E escolha a opção 1 (copiar credenciais)
