# yno hub — Anime Crusaders X

**Versão 3.0.0** · Hub Lua reconstruído para Solara, com organização de abas próxima ao fluxo do LixHub, fundo cinematográfico baseado na referência visual enviada e automações específicas de Anime Crusaders X.

## Loader

Dentro do Anime Crusaders X, execute no Solara:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

Loader de uma linha: [loadstring.txt](loadstring.txt) · Código principal: [yno.lua](yno.lua).

## Painel 3.0.0

- **Overview** — iniciar Story, coletar recompensas, entrar em Unit Hunt e iniciar Smart Macro.
- **Missions** — categorias All, Daily, Infinite, Story, Event e Guide; Claim All; Guidebook; Bounties; Story Quest Grind e entrada em Challenges/Auto Challenge.
- **Story** — seleciona um dos 11 mundos, ato, dificuldade, World Skip ou Individual Act e Matchmaking/Select Stage; Auto Start, Skip, Next e Retry.
- **Unit Hunt** — Hunting Isles, scan Q, aproximação de ProximityPrompt Capture, interação E e tentativa de assistência PERFECT quando marcador e zona dourada são reconhecidos.
- **Free Units** — Anniversary Login, Phoenix/Guidebook, Hesia Free Rewards, YouTube Reward, King's Index e Blank Units.
- **Game** — Auto Vote Start, Skip Wave, Next, Retry, Auto Abilities, Auto Sell helpers e abertura de Settings.
- **Macro** — inicia/para Smart Macro nativo com Loop, This Stage ou Routine.
- **Performance** — Low Effects, Hide Attack Effects, FPS cap e restauração.
- **Settings** — escala, salvar configuração, Stop All e Unload.
- Janela arrastável, wallpaper local, pesquisa, RightShift, minimizar para botão flutuante y e fechar em ×.

## Missões e farming

A aba Missions abre All/Daily/Infinite/Story/Event/Guide e recolhe recompensas concluídas. Auto claim só atua quando uma tela de Quest/Guide/Event Quest já está aberta. O bônus Daily Quests Complete! concede 750 Gems + 10 Trait Remnants após cinco tarefas diárias.

O botão **Start Story quest grind** liga Auto Start, Auto Skip e Auto Next e inicia a rota Story selecionada. Isso ajuda em objetivos de kills e stage clears. Para desafios, o painel abre Play → Challenges e pode iniciar uma Routine do Smart Macro depois de configurar Macro → Dailies → Auto Challenge.

O Guidebook tem 10 tarefas; ao completar todas e reivindicar Guide Quests Complete!, o jogo entrega Phoenix. Algumas tarefas consomem XP Food, unidades, Trait Remnants ou Stat Cubes e continuam exigindo uma escolha consciente do jogador.

Bounties: fale com Navi/Missions, abra Bounties, conclua três objetivos e reivindique 5 Event Tokens + 1 Blank Token. Reroll custa 10.000 Gold e apaga o progresso do cartão.

## Story

A progressão tem 11 mundos: Planet Namak, Marine's Ford, Karakura Town, Shibuya, Demon District, Devil City, Soul Society, West City (Ruined), Culling Games, Doldrey e Sword Arena.

O Story Runner navega por Play → Story → mundo → ato/World Skip → dificuldade → Matchmaking/Select Stage → Start. Auto Next só clica depois de detectar vitória/conclusão; Auto Retry só atua após derrota. World Skip existe nos mundos 1–10, é Normal-only e aplica +900% HP. Sword Arena exige atos individuais.

Para farming real com colocação, upgrades, habilidades e venda, configure Macro → Units e Macro → Placement, depois inicie Loop, This Stage ou uma Routine pré-configurada. O Smart Macro nativo é quem executa a estratégia de batalha.

## Unit Hunt — evento de captura

Unit Hunt exige Level 5 e abre em Events → Unit Hunt → Start Hunt. Tem 39 entradas no Collection Book, 35 entradas separadas na aba Shinies, quatro regiões e cinco Event Quests. Auto Hunt procura ProximityPrompts com ação Capture, aproxima o personagem, usa E e pressiona Q periodicamente para scan. A assistência tenta pressionar Space ao detectar o marcador dentro da zona dourada.

A assistência depende da estrutura da barra que o cliente expõe; se o nome/elemento mudar, faça o timing manual. Acertar o centro dourado dá PERFECT e dano dobrado. As entradas do Book são colecionáveis do evento, não unidades automaticamente adicionadas ao roster de Tower Defense.

## Unidades e recompensas gratuitas

- **Twenty One:** Anniversary Login, Day 1. Daily e Anniversary são abas separadas; reivindique ambas.
- **Phoenix:** recompensa das 10 Guide Quests, após claim da missão final.
- **Hesia Free Rewards:** quatro tarefas sociais; Claim Rewards aparece depois de concluí-las.
- **YouTube Reward:** exige subscrever @32xGames, ativar notificações e informar seu próprio canal para Redeem.
- **King's Index:** Claim All para recompensas de unidades Normal/Shiny já registradas.
- **Shadow (Atomic)** e **Lao (Heart):** cada um custa 30 Blank Tokens; não são gratuitos.

O evento Golden Crusader é permanente: derrotar o inimigo concede um Crusader Token por jogador elegível, uma vez na vida. O token pode ser usado em Items para receber Gems e Trait Remnants. Anniversary Hunt é outra atividade de drops enquanto o evento estiver ativo.

## Limites honestos

O yno hub atua por botões visíveis, prompts normais, movimentação normal do personagem e funções documentadas de input/UI do Solara. Não chama RemoteEvents privados, não altera moedas/inventário no servidor e não tenta contornar anti-cheat.

A sintaxe Lua é verificada pelo GitHub Actions. **Não houve teste em uma sessão real Roblox/Solara neste ambiente**; por isso, a navegação de menus e a detecção da barra de captura ainda precisam ser confirmadas no seu cliente. Os nomes/hierarquias de UI podem mudar após atualizações.
