# yno hub 4.0.3 — matriz real de recursos e paridade

Esta matriz descreve o que está no `yno.lua` da branch `main` e compara com os controles anunciados na [ficha pública do LixHub para Anime Crusaders X](https://robloxscripts.com/script/anime-crusaders-x-lixhub).

**Importante:** “implementado no código” não significa “confirmado em uma partida real”. Não há teste de runtime Roblox/Solara neste repositório. Recursos baseados na interface dependem da hierarquia e dos textos que o cliente do jogo realmente apresentar.

## Comparação com o LixHub

| Área do LixHub | Situação no yno hub 4.0.3 | Observação |
|---|---|---|
| Joiner — 16 modos | Ausente como sistema geral | Há fluxo auxiliar de Story, mas não um Joiner configurável para todos os modos listados. |
| Join Priority | Ausente | Não há fila configurável de prioridade para os 16 modos. |
| Game — Auto Start / Skip | Parcial | Os controles visíveis são procurados por texto; dependem de correspondência com a UI atual. |
| Game — Auto Next / Replay | Experimental | Detecção heurística de vitória/derrota pelo texto da tela e procura de botões Next/Replay. |
| Game — Auto Upgrade / Abilities | Parcial | Integração com opções do Smart Macro nativo; exige que o painel nativo esteja disponível e corresponda aos seletores. |
| Game — Auto Sell Farms / Units | Ausente | Não há sistema completo de venda por onda, por onda específica e na última onda. |
| Game — Portals / Escanor Trial / Kitchen Madness / Boss Rush / Boss Lair | Ausente como módulo completo | Não tratar a existência de outras telas como automação dessas atividades. |
| Performance — efeitos | Parcial | Low Effects e Hide Attack Effects alteram renderização local. |
| Performance — animações / low detail / esconder outros / dano / Low Performance / Black Screen | Ausente | Esses controles da ficha do LixHub ainda não estão implementados como recursos próprios. |
| Performance — FPS | Parcial | FPS cap local, com restauração prevista. |
| Summon | Ausente | Não há Auto Summon completo com banner, alvos, raridade, reserva de recursos e webhook de resultado. |
| Macro | Parcial, integração nativa | Abre/configura o Smart Macro do jogo (This Stage, Loop, Routine). Não é um gravador próprio com JSON, lista persistente e mapas. |
| Auto Reroll — Trait / Stat / Relics / Curse | Ausente | Não há leitura comprovada do resultado nem condição de parada baseada no alvo. |
| Shop | Ausente | Não há automação de compras para as lojas listadas. |
| Webhook | Ausente como módulo de eventos | Não há o sistema completo de endpoint, menções, conclusão e derrota anunciado na ficha. |

## Recursos próprios adicionais do yno hub

| Área | Situação | Comportamento no código |
|---|---|---|
| Story helper | UI automation | Navega por seleção de mundo/ato/dificuldade e entrada, quando os controles esperados existem. |
| Quests | UI automation | Abre categorias e procura ações de claim; depende dos nomes e da janela visível. |
| Unit Hunt | Experimental | Scan Q, prompts de captura, E e assistência PERFECT heurística. |
| Rewards | UI helper | Helpers para login, Hesia, YouTube Reward, King's Index e Blank Units; requisitos externos podem continuar manuais. |
| Settings | Implementado no código | Relatório de UI, self-check, preferências, Stop All e Unload. |
| Interface | Implementado no código | Sidebar, nove páginas, tema dark slate-blue, wallpaper, pesquisa, arrastar, RightShift, minimizar e botão flutuante. |

## Recursos LixHub documentados para a reconstrução

### Joiner
Pause Auto Join; Delay Auto Join; Auto Join Story; Legend; Raid; Challenge; Daily Challenge; Weekly Challenge; Infinite; Weekly Tower; Boss Rush; Boss Lair; Events; Portal; Infinity Castle; Tournament; Infinite Tournament; Testing Zone.

### Join Priority
Custom Join Priority for All Modes; Automatically Skip Unavailable Modes.

### Game
Auto Skip Wave; Auto Start; Auto Replay; Auto Next; Disable Boss Dialogue; Hide Ability Cutscenes; Streamer Mode; Anti AFK; Auto Upgrade; Auto Use Abilities; Auto Sell Farms; Auto Sell Farms Wave; Auto Sell Farms On Last Wave; Auto Sell Units; Auto Sell Units Wave; Auto Sell Units On Last Wave; Portals; Escanor Trial; Kitchen Madness; Kitchen Card Priorities; Boss Rush; Boss Lair.

### Performance
Low Quality Effects; Hide Attack Effects; Hide Attack Animations; Low Detail Units; Hide Other Players' Units; Hide Damage Numbers; Low Performance Mode; Black Screen; Limit FPS; FPS Limit.

### Summon
Auto Summon; Select Banner; Summon Targets; Summon Rarity Targets; Unselect If Summoned; Pull Amount; Keep Gems; Keep Anniversary Tickets; Send Summon Webhooks; Notify on Rarities; Notify on Units.

### Macro
Create Macro; Record Macro; Playback Macro; Delete Macro; Refresh Macro List; Playback Mode; No Ignore Sell Timing; Export Macro (Copy JSON); Import Macro JSON; Check Macro Units; Copy Loadout; Macro Maps.

### Auto Reroll
Trait; Stat; Relics; Curse.

### Shop
Gold Shop; Event Shop; Emote Shop; Babylon Raid Shop; Cell Raid Shop; Sakamato Raid Shop; Shinjuku Raid Shop; Boss Rush: Control Shop; Boss Rush: Perfection Shop; Kitchen Madness Shop; Einz's Shop.

### Webhook
Input Webhook; Input Discord ID (mentions); Send on Stage Finished; Ping on Stage Finished; Ping on Loss; More (sem detalhes na ficha).

## Testes automáticos existentes

GitHub Actions executa:
- `luac5.4 -p yno.lua`;
- `luac5.4 -p scripts/static-check.lua`;
- `lua5.4 scripts/static-check.lua yno.lua`.

Esses testes verificam sintaxe e invariantes estáticos. Não executam uma partida Roblox, não confirmam Remote/UI do cliente e não provam que cada automação produziu o resultado esperado.

## Arquivo recebido em 17/11/2026

O arquivo anexado `Pasted text(1).txt` foi lido e revisado. **Ele não substituiu `yno.lua`** porque contém bloqueios de escopo, reexecução de ações durante a verificação, resolução inconsistente de remotes, opções desconectadas e ausência de cancelamento global. A revisão técnica está em [imported-script-review.md](imported-script-review.md).

## Referências

- LixHub — Anime Crusaders X: https://robloxscripts.com/script/anime-crusaders-x-lixhub
- LixHub histórico — Anime Crusaders: https://scriptblox.com/script/Anime-Crusaders-LixHub-81563

O catálogo de nomes foi extraído da publicação pública. A publicação não divulga o código ofuscado, os algoritmos internos nem todos os detalhes visuais do painel. Cores exatas, dimensões e espaçamentos ainda precisam de uma captura visual legível do painel original.
