# Changelog

## 3.2.0 — 17 de novembro de 2026

- Refeito o layout de Game em duas colunas reais: Game / Wave Actions, com linhas compactas inspiradas na referência LixHub.
- Adotada paleta azul-aço escura, sem degradês roxos/cianos, e a foto anime solicitada como fundo.
- O scanner de botões ranqueia correspondência exata, contexto, dimensão e hierarquia; o contexto deixou de ser um filtro absoluto.
- O envio do clique usa mousemoveabs + mouse1press + mouse1release do Solara; o cooldown só é iniciado após o input ser enviado.
- Ações passam a informar quando um botão não foi localizado ou quando a execução retornou falha.
- Settings ganhou Copy Game UI report para copiar nomes, textos e hierarquia de até 180 controles visíveis.
- O helper das opções nativas procura o toggle pelo rótulo e proximidade, em vez de depender somente do nome interno.



## 3.2.0 — 17 de novembro de 2026

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
