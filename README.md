# 📚 StudySync

**StudySync** é um aplicativo mobile para organização e participação em reuniões de estudo. Ele oferece check-in baseado em localização, chat offline via rede local e gamificação com rankings por grupo.

---

## 🚀 Funcionalidades

### ✅ Funcionalidades principais

- 📅 **Marcar Reuniões**
  - Criação de reuniões com data, hora e localização
- 🔐 **Autenticação de Usuário**
  - Cadastro e login com Supabase Auth
- 📍 **Check-in com Localização**
  - Verifica se o usuário está próximo ao local da reunião via GPS
- 💬 **Chat Offline**
  - Comunicação local entre participantes por socket TCP usando Wi-Fi ou hotspot
  - Suporte a envio de mensagens e imagens
- 🏆 **Sistema de Pontuação**
  - Pontos atribuídos por presença
  - Ranking de participantes por grupo

### 🔧 Em desenvolvimento

- 🎖️ Sistema de conquistas e metas
- 📲 Integração com sensores (ex: acelerômetro)
- 🔗 Alternativa com Bluetooth P2P

---

## 🛠️ Tecnologias utilizadas

- **Flutter** — desenvolvimento multiplataforma
- **Supabase** — backend (auth + PostgreSQL + storage)
- **Geolocator** — localização em tempo real
- **TCP Sockets** — comunicação offline local
- **Hive** — armazenamento local (grupos, cache)
- **Google Maps** — escolha interativa de local

---
## Contribuidores

- **Caroline Ribeiro**
- **Mateus da Fonte**
- **Victor Milhomem**
