# 🚀 INSTALAÇÃO AUTOMÁTICA - DESKTOP 24/7

## 📋 PRÉ-REQUISITOS

✅ **Docker Desktop** instalado e rodando  
✅ **Executar como ADMINISTRADOR**  
✅ **Conexão com internet** (vai baixar ~2GB de dados)

---

## 🎯 INSTALAÇÃO COMPLETA (1 CLIQUE)

### 1️⃣ Execute como Administrador:

```
INSTALADOR_AUTOMATICO.bat
```

**Clique com botão direito → "Executar como administrador"**

### 2️⃣ O que será instalado automaticamente:

- ✅ **Node.js** (se não tiver)
- ✅ **Dependências NPM** (node-geocoder, express, etc)
- ✅ **Cloudflared** (tunnel)
- ✅ **Cloudflare Tunnel** configurado (geocoder.urbanmt.com.br)
- ✅ **Nominatim** (Docker, dados do Brasil)
- ✅ **Arquivo .env** com configurações
- ✅ **NSSM** (gerenciador de serviços Windows)
- ✅ **2 Serviços Windows** para rodar 24h:
  - `GeocoderServer` (porta 3002)
  - `CloudflareTunnel` (geocoder.urbanmt.com.br)

### 3️⃣ Login no Cloudflare (única vez)

Durante a instalação, o navegador vai abrir:
- Faça login no Cloudflare
- Selecione o domínio: **urbanmt.com.br**
- Autorize

### 4️⃣ Aguarde a importação do Nominatim

**Primeira vez:** ~2 horas para importar dados do Brasil

Acompanhe:
```bash
docker logs -f nominatim-mato-grosso
```

---

## ✅ PRONTO!

Após a instalação:

🌐 **URL Permanente (24h):**
```
https://geocoder.urbanmt.com.br
```

🔄 **Serviços iniciam automaticamente** com o Windows!

📊 **Endpoints:**
- Health: `https://geocoder.urbanmt.com.br/health`
- Geocoding: `https://geocoder.urbanmt.com.br/api/search_reverse?latitude=LAT&longitude=LON`

---

## 🛠️ GERENCIAR SERVIÇOS

### Ver Status:
```bash
sc query GeocoderServer
sc query CloudflareTunnel
```

### Parar Serviços:
```bash
nssm stop GeocoderServer
nssm stop CloudflareTunnel
```

### Iniciar Serviços:
```bash
nssm start GeocoderServer
nssm start CloudflareTunnel
```

### Reiniciar Serviços:
```bash
nssm restart GeocoderServer
nssm restart CloudflareTunnel
```

### Ver Logs:
```bash
type logs\server.log
type logs\tunnel.log
```

### Desinstalar Serviços:
```
DESINSTALAR_SERVICOS.bat
```

---

## 🔍 VERIFICAR SE ESTÁ FUNCIONANDO

### Local:
```bash
curl http://localhost:3002/health
```

### Internet:
```bash
curl https://geocoder.urbanmt.com.br/health
```

### Teste completo:
```bash
curl "https://geocoder.urbanmt.com.br/api/search_reverse?latitude=-10.166061&longitude=-54.935305"
```

Deve retornar: **Matupá, Mato Grosso**

---

## 🐛 TROUBLESHOOTING

### Serviço não inicia

1. Verifique se Docker está rodando:
   ```bash
   docker ps
   ```

2. Verifique se Nominatim está pronto:
   ```bash
   docker logs nominatim-mato-grosso | findstr "Apache started"
   ```

3. Teste servidor local:
   ```bash
   curl http://localhost:3002/health
   ```

### Erro 404 na URL permanente

1. Verifique se tunnel está rodando:
   ```bash
   sc query CloudflareTunnel
   ```

2. Veja logs do tunnel:
   ```bash
   type logs\tunnel.log
   ```

3. Reinicie tunnel:
   ```bash
   nssm restart CloudflareTunnel
   ```

### Docker não encontrado

1. Instale Docker Desktop:
   https://www.docker.com/products/docker-desktop

2. Execute novamente: `INSTALADOR_AUTOMATICO.bat`

---

## 📦 ESTRUTURA DE ARQUIVOS

```
geocoder_reverse-1/
├── INSTALADOR_AUTOMATICO.bat     ← CLIQUE AQUI (como admin)
├── DESINSTALAR_SERVICOS.bat      ← Remover serviços
├── start_geocoder_permanent.bat  ← Iniciar manual (sem serviço)
├── stop_geocoder.bat             ← Parar manual
├── server.js                     ← Servidor
├── index.js                      ← Entry point
├── .env                          ← Configurações (criado auto)
└── logs/                         ← Logs dos serviços
    ├── server.log
    ├── server-error.log
    ├── tunnel.log
    └── tunnel-error.log
```

---

## 🎯 RESUMO

| Item | Status |
|------|--------|
| **Instalação** | 1 clique (como admin) |
| **Tempo 1ª vez** | ~2 horas (importação Nominatim) |
| **Reinicializações** | Automático (serviço Windows) |
| **URL** | https://geocoder.urbanmt.com.br (fixa) |
| **Performance** | 60-75 req/s (150 pico com cache) |
| **Limite** | Ilimitado (Nominatim local) |
| **Custo** | Grátis |

---

## 🆘 SUPORTE

Se algo não funcionar:

1. Veja os logs: `type logs\server.log`
2. Verifique Docker: `docker ps`
3. Teste local: `curl http://localhost:3002/health`
4. Reinicie serviços: `nssm restart GeocoderServer`

---

**🎉 Após a instalação, o sistema roda 24/7 automaticamente!**
