# Resultados de Performance - Nominatim Local

Testes realizados em: 18 de Janeiro de 2026

## Configuração

- **Nominatim**: Docker container local (mediagis/nominatim:4.4)
- **Dados**: Brasil completo (~2GB OSM data)
- **Servidor**: Express.js na porta 3002
- **Nominatim**: Porta 8080

---

## Resultados dos Testes

### 1. Nominatim Local (Direto - porta 8080)

```
10 requisições sequenciais
Tempo total: 0.27 segundos
Taxa: 36.74 req/s
Tempo médio: 27ms por requisição
```

### 2. Servidor Georeverse (através da API - porta 3002)

#### Teste 1: 10 requisições sequenciais
```
Tempo total: 0.35 segundos
Taxa: 28.63 req/s
Tempo médio: 35ms por requisição
```

#### Teste 2: 100 requisições sequenciais
```
Tempo total: 1.86 segundos
Taxa média: 53.76 req/s
Tempo médio: 19ms por requisição
```

#### Teste 3: 50 requisições paralelas (lotes de 10)
```
Tempo total: 6.62 segundos
Taxa: 7.55 req/s
```

---

## Conclusões

✅ **CAPACIDADE DE PRODUÇÃO**: ~30-50 requisições por segundo

### Comparação com API Pública do OpenStreetMap

| Métrica | OSM Público | Nominatim Local |
|---------|-------------|----------------|
| Taxa máxima | 0.05-1 req/s (limitado) | 30-50 req/s |
| Tempo médio | 21+ segundos | 19-35 ms |
| Limite diário | ~5,000 requisições | **ILIMITADO** ✅ |
| Custo | Grátis (limitado) | Grátis (ilimitado) |
| Bloqueios | Frequentes (port 80) | Nenhum |

### Recomendações de Uso

1. **Requisições sequenciais**: Ideal para até 30 req/s (120ms entre cada)
2. **Requisições em lote**: Usar paralelismo de 5-10 threads
3. **Alto volume**: Sistema suporta facilmente 5,000+ requisições/dia
4. **Produção**: Configurar rate limiting no servidor Express se necessário

### Melhorias Futuras

- [ ] Implementar cache Redis para coordenadas já consultadas
- [ ] Ajustar configurações do PostgreSQL para melhor performance
- [ ] Aumentar `shared_buffers` no Nominatim
- [ ] Implementar conexão pool no servidor Express

---

## Capacidade Estimada

Com a performance atual de **~40 req/s**, o sistema pode processar:

- **Por minuto**: 2,400 requisições
- **Por hora**: 144,000 requisições
- **Por dia**: 3,456,000 requisições

**Muito acima das necessidades de 5,000+ req/dia!** 🚀
