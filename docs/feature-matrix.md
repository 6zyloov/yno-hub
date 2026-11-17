# yno hub — matriz de recursos 3.0.0

| Área | Estado | O que realmente faz |
|---|---|---|
| Panel UI | Implementado | Layout LixHub-inspired, wallpaper local, sidebar, search, janela arrastável, minimize/floating y, RightShift e Unload. |
| Missions | UI automation | Abre All/Daily/Infinite/Story/Event/Guide e tenta Claim All / Claim Rewards concluídos. Auto claim age apenas enquanto uma tela relacionada está aberta. |
| Daily quests | Parcial | Pode coletar as tarefas concluídas. O progresso de kills/stages/challenges depende das partidas e dos objetivos atualmente atribuídos pelo jogo. |
| Guidebook / Phoenix | Parcial | Abre Guide e reivindica recompensas visíveis; Phoenix exige completar as dez Guide Quests antes do claim final. |
| Bounties | Parcial | Abre a tela Bounties e tenta reivindicar cartões concluídos. Não rerrola automaticamente, pois isso custa Gold e apaga progresso. |
| Story Runner | UI automation | Navega Play → Story → World → Act/World Skip → Difficulty → Matchmaking/Select Stage → Start com controles visíveis. |
| Auto Next / Retry / Skip / Vote Start | UI automation | Aciona os botões visíveis correspondentes. Não desbloqueia atos, mundos ou modos bloqueados. |
| Auto Farm | Native integration | Abre/inicia/para o Smart Macro nativo. Posicionamento, upgrades, venda e estratégia dependem de slots/zonas configurados no jogo. |
| Unit Hunt | Experimental client automation | Procura ProximityPrompts Capture, aproxima o jogador, usa E, pressiona Q para scan e tenta acertar Space quando detecta marker + gold/perfect zone por nomes de UI. |
| Unit Hunt Book / Event Quests | UI + guide | Abre Book/Event Quests e tenta coletar recompensas; coleção não é roster de unidades TD. |
| Free units | UI + guide | Phoenix por 10 Guide Quests; Blank Unit claim explícito para Shadow (Atomic)/Lao (Heart), 30 Blank Tokens cada. |
| Performance | Client-side | Low Effects, Hide Attack Effects, FPS cap e restauração de estado. |

## Validação e limites

- GitHub Actions valida a sintaxe Lua 5.4.
- A API pública do Solara foi consultada para getcustomasset, filesystem, input, GUI e FPS.
- O wallpaper é baixado do repositório para o filesystem do executor e usado com getcustomasset; sem esse recurso, o painel abre com fundo escuro simples.
- **Não houve teste em sessão real Roblox/Solara neste ambiente.** O Story Runner depende dos rótulos atuais do Play menu; o Perfect Capture Assist depende dos nomes/hierarquia que a barra de captura expõe ao cliente.
- Nenhum código altera inventário/moedas do servidor, chama RemoteEvents privados ou tenta contornar anti-cheat.
