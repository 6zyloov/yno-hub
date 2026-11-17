# yno hub — Anime Crusaders X

**Versão 3.0.0** · Hub Lua refeito para Solara, com organização de abas próxima ao fluxo do LixHub, fundo cinematográfico baseado na referência visual enviada e automações específicas de Anime Crusaders X.

## Loader

Dentro do Anime Crusaders X, execute no Solara:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

Loader de uma linha: [loadstring.txt](loadstring.txt) · Código principal: [yno.lua](yno.lua).

## Painel 3.0.0

- **Overview** — ações rápidas de Story, coleta de recompensas, Unit Hunt e Smart Macro.
- **Missions** — categorias All, Daily, Infinite, Story, Event e Guide; Claim All; Guidebook e Bounties.
- **Story** — seleciona um dos 11 mundos, ato, dificuldade, World Skip ou Individual Act e Matchmaking/Select Stage.
- **Unit Hunt** — entrada nas Hunting Isles, scan Q, aproximação de ProximityPrompt de captura, interação E e tentativa de assistência PERFECT quando os elementos da barra são reconhecidos.
- **Free Units** — roteiro de Phoenix pelo Guidebook e resgate de Shadow (Atomic)/Lao (Heart) com Blank Tokens.
- **Game** — Auto Vote Start, Skip Wave, Next, Retry, Auto Abilities e atalhos de configuração.
- **Macro** — inicia/para o Smart Macro nativo, com Loop, This Stage ou Routine.
- **Performance** — Low Effects, Hide Attack Effects, FPS cap e restauração.
- **Settings** — escala, salvar configuração, Stop All e Unload.
- Janela arrastável, fundo ilustrado local, pesquisa, RightShift, minimizar para botão flutuante y e fechar em ×.

## Automação de missões

A aba Missions abre as categorias do menu Quests e coleta recompensas concluídas. O toggle Auto claim só atua quando uma tela de Quest/Guide/Event Quest já está aberta. Daily Quest Complete! concede 750 Gems e 10 Trait Remnants após cinco tarefas diárias concluídas.

O Guidebook tem 10 tarefas. Ao completar todas e reivindicar Guide Quests Complete!, o jogo entrega Phoenix. As tarefas incluem rolar Traits e Stats, alimentar/fundir unidades e colocar/vender unidades dentro de partidas. A automação de batalha e o Smart Macro ajudam nos objetivos de fase; tarefas que gastam itens ou exigem escolhas manuais não são executadas sem ação explícita.

## Story

A progressão tem 11 mundos: Planet Namak, Marine's Ford, Karakura Town, Shibuya, Demon District, Devil City, Soul Society, West City (Ruined), Culling Games, Doldrey e Sword Arena.

O Story Runner navega pelos botões visíveis de Play → Story → mundo → ato/World Skip → dificuldade → Matchmaking/Select Stage → Start. Auto Next e Auto Retry podem avançar pelos controles que o próprio jogo disponibiliza. World Skip existe nos mundos 1–10, é Normal-only e aplica +900% HP; Sword Arena exige atos individuais.

Para farm que posiciona e atualiza unidades, configure primeiro Macro → Units e Macro → Placement. Em seguida inicie Loop, This Stage ou uma Routine pré-configurada pela aba Macro do yno hub.

## Unit Hunt — evento de captura

Unit Hunt exige Level 5 e é acessado em Events → Unit Hunt → Start Hunt. O evento tem 39 entradas no Collection Book, uma aba separada com 35 Shinies, quatro regiões e cinco Event Quests. O Auto Hunt procura ProximityPrompts com ação Capture, aproxima o personagem e usa E; pressiona Q periodicamente para procurar raros e tenta acertar Space quando identifica marcador e zona dourada pela interface.

A assistência de captura depende dos nomes e da estrutura dos elementos de UI que o jogo expõe. Se a barra mudar, faça o timing manual: a wiki recomenda acertar o centro dourado para PERFECT, que causa dano dobrado. As 39 capturas do Book são colecionáveis do evento, não unidades automaticamente adicionadas ao roster de Tower Defense.

## Unidades e custos

- **Phoenix:** recompensa das 10 Guide Quests, após reivindicar a missão de conclusão.
- **Shadow (Atomic):** 30 Blank Tokens.
- **Lao (Heart):** 30 Blank Tokens.

Shadow (Atomic) e Lao (Heart) não são gratuitos; o botão de claim é uma ação explícita e exige que você confira seu saldo.

## Limites honestos

O yno hub só atua por botões visíveis, prompts normais, movimentação normal do personagem e funções documentadas de input/UI do Solara. Não chama RemoteEvents privados, não altera moedas ou inventário no servidor e não tenta contornar anti-cheat.

A sintaxe Lua é verificada pelo GitHub Actions. **Não foi possível executar uma sessão real de Roblox/Solara neste ambiente**; por isso, a navegação de menus e a detecção dos elementos da barra de captura ainda precisam ser confirmadas no seu cliente. Os nomes/hierarquias de UI podem mudar em atualizações do jogo.

## Referências

- [LixHub — listagem pública de recursos](https://scriptblox.com/script/Anime-Crusaders-LixHub-81563)
- [Quests e Guidebook](https://anime-crusaders-x.wiki/quests/)
- [Story Worlds](https://anime-crusaders-x.wiki/story-worlds/)
- [Unit Hunt](https://anime-crusaders-x.wiki/unit-hunt/)
- [Bounties](https://anime-crusaders-x.wiki/bounties/)
- [Smart Macro](https://anime-crusaders-x.wiki/macro/)
- [Patch notes](https://anime-crusaders-x.wiki/updates/)
- [API Solara](https://solara.gg/docs/)
