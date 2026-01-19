# 🗺️ CONFIGURAR NOMINATIM NO EASYPANEL - MATO GROSSO

## 📋 PASSO A PASSO COMPLETO

### PASSO 1️⃣: Acessar EasyPanel
1. Acesse seu EasyPanel: `http://148.230.73.27:3000`
2. Faça login
3. Selecione o projeto: **geo_reverse**

---

### PASSO 2️⃣: Criar Novo Serviço
1. Clique em **"+ Service"** (botão superior direito)
2. Escolha: **"App"**
3. Clique em **"Create"**

---

### PASSO 3️⃣: Configurações Básicas
**Nome do serviço:**
```
nominatim-mt
```

**Tipo:**
- Selecione: **Docker Image**

**Imagem Docker:**
```
mediagis/nominatim:4.4
```

---

### PASSO 4️⃣: Variáveis de Ambiente (Environment)
Clique em **"Environment"** e adicione cada variável:

| Key | Value |
|-----|-------|
| `PBF_URL` | `https://download.geofabrik.de/south-america/brazil-latest.osm.pbf` |
| `REPLICATION_URL` | `https://download.geofabrik.de/south-america/brazil-updates/` |
| `IMPORT_WIKIPEDIA` | `false` |
| `NOMINATIM_PASSWORD` | `nominatim_mt_2026` |
| `IMPORT_STYLE` | `admin` |

**Como adicionar:**
- Clique "+ Add Variable"
- Digite o **Key** (nome da variável)
- Digite o **Value** (valor)
- Repita para cada variável acima

---

### PASSO 5️⃣: Configurar Domínio/Porta
1. Vá para aba **"Domains"**
2. Clique **"Add Domain"**
3. Configure:
   - **Domain**: `nominatim.urbanbmt.com.br` (ou o que preferir)
   - **Port**: `8080`
   - **Protocol**: `http`

**OU** use apenas a porta interna:
- Port: `8080` (será acessível como `nominatim-mt:8080` internamente)

---

### PASSO 6️⃣: Configurar Volume (ESSENCIAL!)
1. Vá para aba **"Storage"** ou **"Volumes"**
2. Clique **"Add Mount"**
3. Configure:
   - **Mount Path**: `/var/lib/postgresql/14/main`
   - **Size**: `20` GB (mínimo recomendado)
   - **Type**: `Volume` (persistente)

⚠️ **IMPORTANTE**: Sem o volume, os dados serão perdidos se o container reiniciar!

---

### PASSO 7️⃣: Recursos (Resources)
1. Vá para aba **"Resources"**
2. Configure:
   - **Memory**: `2048` MB (mínimo 2GB)
   - **CPU**: `1000` millicores (1 core)
   - **Shared Memory**: `2048` MB (importante para PostgreSQL)

---

### PASSO 8️⃣: Deploy!
1. Clique no botão **"Deploy"** (canto superior direito)
2. Aguarde o container iniciar

---

## ⏱️ ACOMPANHAR A IMPORTAÇÃO

### Ver Logs em Tempo Real:
1. No serviço `nominatim-mt`, clique em **"Logs"**
2. Você verá mensagens como:
   ```
   Downloading PBF file...
   Import started...
   Processing...
   ```

### Tempo Estimado:
- **Download**: 5-15 minutos (~2GB)
- **Importação**: 1-2 horas (Brasil inteiro)
- **Total**: ~2 horas até estar pronto

### Quando estiver pronto, você verá:
```
INFO: Setup finished
INFO: Starting Apache
```

---

## 🧪 TESTAR O NOMINATIM

Após a importação concluir, teste:

**Cuiabá, MT:**
```
http://nominatim.urbanbmt.com.br/reverse?lat=-15.5989&lon=-56.0949&format=json
```

**Campo Grande (se quiser testar fora MT):**
```
http://nominatim.urbanbmt.com.br/reverse?lat=-20.4486&lon=-54.6295&format=json
```

**Health Check:**
```
http://nominatim.urbanbmt.com.br/status.php
```

---

## 🔗 CONECTAR AO SEU SERVIDOR GEOREVERSE

### PASSO 1: Editar serviço `georeverse`
1. No EasyPanel, abra o serviço **georeverse**
2. Vá para **Environment**
3. Adicione/modifique estas variáveis:

| Key | Value |
|-----|-------|
| `PROVIDER_DEFAULT` | `openstreetmap` |
| `OSM_SERVER` | `http://nominatim-mt:8080` |
| `OSM_USER_AGENT` | `geocoder-mato-grosso` |

### PASSO 2: Redeploy
1. Salve as alterações
2. Clique em **"Restart"** no serviço georeverse

---

## ✅ PRONTO!

Agora você tem:
- ✅ Nominatim rodando na VPS
- ✅ Dados do Brasil (foco em Mato Grosso)
- ✅ Geocoding ILIMITADO
- ✅ Sem custos por requisição
- ✅ Disponível 24/7

---

## 📊 CUSTOS MENSAIS

**EasyPanel:**
- Volume 20GB: ~$2-4/mês
- Container 2GB RAM: ~$5-10/mês
- **TOTAL: ~$10-15/mês**

**Compare com APIs:**
- LocationIQ: $50/mês (10k extras)
- Google Maps: $500/mês (100k requisições)
- OpenCage: $50/mês (10k extras)

**Economia: ~$40-490/mês!** 💰

---

## 🆘 TROUBLESHOOTING

### Container não inicia:
- Verifique os logs
- Certifique-se que tem 2GB+ RAM alocado
- Verifique se o volume foi criado

### Importação travou:
- É normal demorar 1-2h
- Verifique logs para ver progresso
- Se travar por mais de 3h, reinicie o container

### Teste não funciona:
- Espere a importação terminar completamente
- Verifique logs: deve mostrar "Apache started"
- Teste o status: `/status.php`

### Erro de memória:
- Aumente RAM para 4GB
- Aumente Shared Memory para 2GB

---

## 📝 COMANDOS ÚTEIS

**Ver logs:**
```bash
docker logs nominatim-mt -f
```

**Reiniciar:**
```bash
docker restart nominatim-mt
```

**Ver status:**
```bash
docker ps | grep nominatim
```

---

## 🎯 PRÓXIMOS PASSOS

1. ✅ Deploy Nominatim (este guia)
2. ⏳ Aguardar importação (1-2h)
3. ✅ Testar endpoints
4. ✅ Conectar ao georeverse
5. ✅ Usar no n8n com URL: `http://geo_reverse_georeverse:3002/api/search_reverse`

**ILIMITADO E GRÁTIS!** 🚀
