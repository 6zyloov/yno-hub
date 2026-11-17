# yno hub — matriz de recursos 3.0.1

| Área | Estado | O que realmente faz |
|---|---|---|
| Panel UI | Implementado | Layout próximo ao LixHub, wallpaper local baseado na referência enviada, sidebar, search, janela arrastável, botão flutuante y, RightShift e Unload. |
| Missions | UI automation | Abre All/Daily/Infinite/Story/Event/Guide, Claim All, Bounties, Story grind, Challenges e início de Auto Challenge Routine pré-configurada. |
| Daily quests | Parcial | Coleta objetivos concluídos; Start Story quest grind ajuda em kills/stage clears com Auto Start/Skip/Next. Challenge/Summoning dependem do objetivo atual e do uso do jogo. |
| Guidebook / Phoenix | Parcial | Abre Guide e reivindica recompensas visíveis; Phoenix exige as dez Guide Quests. |
| Login Rewards / Twenty One | UI automation | Alterna Daily e Anniversary e tenta Claim em cada tab separadamente. Anniversary Day 1 entrega Twenty One. |
| Hesia / YouTube / Index | UI automation | Abre Hesia Free Rewards e Claim Rewards; preenche o campo YouTube com o nome informado pelo usuário e pressiona Redeem; aproxima-se de King e tenta Index Claim All. Não completa tarefas sociais nem a inscrição externa. |
| Bounties / Blank Units | Parcial | Aproxima-se de Navi, abre Bounties e reivindica cartões concluídos. Blank Unit claim é explícito e custa 30 Blank Tokens. |
| Story Runner | UI automation | Play → Story → World → Act/World Skip → Difficulty → Matchmaking/Select Stage → Start com controles visíveis. |
| Auto Next / Retry / Skip / Vote Start | UI automation | Aciona controles visíveis; Next só após vitória e Retry só após derrota. Não desbloqueia mundos/atos. |
| Auto Farm | Native integration | Abre/inicia/para Smart Macro nativo. Posicionamento, upgrades, venda e estratégia dependem de slots/zonas configurados no jogo. |
| Unit Hunt | Experimental client automation | Procura ProximityPrompts Capture, move o personagem, usa E, pressiona Q para scan e tenta Space ao detectar marker + gold/perfect zone por nome/geometria/cor. |
| Anniversary Hunt / Golden Crusader | UI helper | Abre os painéis de evento e permite usar Crusader Token do inventário; não controla drops RNG. |
| Unit Hunt Book / Event Quests | UI + guide | Abre Book/Event Quests e tenta coletar recompensas; Book não é roster de unidades TD. |
| Free units | UI + guide | Twenty One via Anniversary Login, Phoenix via Guidebook; Shadow (Atomic)/Lao (Heart) custam 30 Blank Tokens cada. |
| Performance | Client-side | Low Effects, Hide Attack Effects, FPS cap e restauração. |

## Validação e limites

- GitHub Actions valida a sintaxe Lua 5.4.
- API pública Solara consultada para getcustomasset, filesystem, input, GUI e FPS.
- Wallpaper é baixado do repositório para o filesystem do executor e usado via getcustomasset; se não estiver disponível, o painel abre com fundo escuro.
- **Não houve teste em sessão real Roblox/Solara neste ambiente.** Story Runner depende dos rótulos atuais de Play; Perfect Capture Assist depende da UI da barra de captura.
- Nenhum código altera inventário/moedas do servidor, chama RemoteEvents privados ou tenta contornar anti-cheat.
