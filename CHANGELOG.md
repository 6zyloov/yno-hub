# Changelog

## 3.0.1 — 17 de novembro de 2026

Revisão estática adicional do código principal.

- Story Runner agora encerra em Matchmaking após iniciar a busca, e só procura o botão Start quando a rota escolhida é Select Stage.
- Collection Book tenta abrir Events → Unit Hunt → Book, em vez de parar depois de abrir a página do evento.
- Claims de Quests, Guidebook, Bounties, Login Rewards, Hesia, YouTube, Blank Units e Crusader Token passaram a exigir contexto visual mais específico.
- Auto Hunt limita o envio repetido de E no mesmo ProximityPrompt.
- A aproximação de Navi, Hesia e King não reinicia Humanoid:MoveTo a cada ciclo; também ganhou mais tempo de navegação.
- O wallpaper é carregado em segundo plano depois que a janela aparece.
- Notificações idênticas são limitadas para evitar spam de mensagens.
- Chaves de cooldown por botão usam o caminho completo da instância, evitando colisões entre botões com o mesmo nome.
- Referências a APIs do executor foram comparadas com a documentação pública do Solara.

### Verificações

- GitHub Actions: luac5.4 -p yno.lua.
- Varredura estática: 88 funções locais, sem nomes duplicados.
- APIs específicas do executor identificadas na build têm documentação pública no Solara.
- Nenhuma chamada a RemoteEvent:FireServer() ou RemoteFunction:InvokeServer() encontrada.

### Limite

Esta versão **não foi executada numa sessão ao vivo do Roblox/Solara neste ambiente**. A verificação de sintaxe e a revisão estática não provam que os rótulos/hierarquias atuais de cada menu do Anime Crusaders X serão encontrados nem que o assistente de PERFECT reconheça todas as variantes da barra de captura.
