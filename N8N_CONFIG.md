# 📋 CONFIGURAÇÃO DO N8N - HTTP REQUEST

## ⚙️ Configuração do Nó HTTP Request

### 1️⃣ Configurações Básicas

**Method (Método):**
```
GET
```

**URL:**
```
https://mediterranean-bones-combined-stops.trycloudflare.com/api/search_reverse
```

⚠️ **IMPORTANTE**: Cole a URL completa SEM usar expressões/variáveis

---

### 2️⃣ Query Parameters (Parâmetros)

Clique em **"Add Parameter"** e adicione:

**Parameter 1:**
- **Name:** `latitude`
- **Value:** `{{ $json.pickup_latitude }}`

**Parameter 2:**
- **Name:** `longitude`  
- **Value:** `{{ $json.pickup_longitude }}`

---

### 3️⃣ Outras Configurações

**Response Format (Formato de Resposta):**
```
JSON
```

**Authentication (Autenticação):**
```
None
```

---

## 📊 Como Acessar os Dados (Próximo Nó)

Depois do HTTP Request, use:

```javascript
// Cidade
{{ $json.results[0].city }}

// Estado
{{ $json.results[0].state }}

// Endereço completo
{{ $json.results[0].formattedAddress }}

// País
{{ $json.results[0].country }}

// Verificar se foi pulado (0,0)
{{ $json.skipped }}
```

---

## 🔍 Exemplo de Resposta

### Coordenadas válidas:
```json
{
  "success": true,
  "results": [
    {
      "latitude": -9.6655602,
      "longitude": -56.4758122,
      "city": "Paranaíta",
      "state": "Mato Grosso",
      "country": "Brasil",
      "formattedAddress": "Paranaíta, Mato Grosso, Brasil"
    }
  ]
}
```

### Coordenadas 0,0:
```json
{
  "success": true,
  "results": [
    {
      "latitude": 0,
      "longitude": 0,
      "city": "cidade não informada",
      "state": "",
      "country": "",
      "formattedAddress": "cidade não informada"
    }
  ],
  "skipped": true
}
```

---

## ⚠️ TROUBLESHOOTING

### Erro "Invalid URL"
- ✅ Cole a URL COMPLETA no campo URL (não use expressões ali)
- ✅ Use expressões APENAS nos Query Parameters
- ✅ Certifique-se que pickup_latitude e pickup_longitude existem nos dados

### Teste Manual
No n8n, clique em "Fetch from URL" com estes dados de teste:
- **latitude:** -10.166061
- **longitude:** -54.935305

Deve retornar: Matupá, Mato Grosso

---

## 🎯 Template de Configuração (JSON)

Se preferir, copie esta configuração e cole no n8n:

```json
{
  "parameters": {
    "method": "GET",
    "url": "https://mediterranean-bones-combined-stops.trycloudflare.com/api/search_reverse",
    "options": {},
    "queryParameters": {
      "parameters": [
        {
          "name": "latitude",
          "value": "={{ $json.pickup_latitude }}"
        },
        {
          "name": "longitude",
          "value": "={{ $json.pickup_longitude }}"
        }
      ]
    }
  }
}
```
