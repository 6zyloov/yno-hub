# Fontes — yno hub 4.0.2

Pesquisa em 17 de novembro de 2026. A wiki do Anime Crusaders X é comunitária; as descrições abaixo registram os workflows e nomes que ela documenta, não garantem que cada elemento de UI permaneça igual em toda atualização.

| Tema | Referência |
|---|---|
| Solara V3 APIs: mouse, keyboard, filesystem, getcustomasset, gethui, FPS | https://solara.gg/docs/ |
| Roblox GuiObject / ScreenGui UI reference | https://create.roblox.com/docs/reference/engine/classes/GuiObject |
| Smart Macro: This Stage, Loop, Routine, Pause/Stop/Open, Slots e Placement | https://anime-crusaders-x.wiki/macro/ |
| Story menu, Normal/Hard, Matchmaking/Select Stage, World Skip | https://anime-crusaders-x.wiki/story-worlds/ |
| Quest categories, Daily rewards, Guidebook e Phoenix | https://anime-crusaders-x.wiki/quests/ |
| Unit Hunt: Q/E, PERFECT, Book, regions e Event Quests | https://anime-crusaders-x.wiki/unit-hunt/ |
| Login Rewards, Twenty One, Hesia, YouTube Reward e King's Index | https://anime-crusaders-x.wiki/free-rewards/ |
| Bounties e Blank Tokens | https://anime-crusaders-x.wiki/bounties/ |
| Configurações do jogo / Auto Retry, Auto Next, Auto Vote Start | https://anime-crusaders-x.wiki/settings/ |
| Patch notes e mudanças de UI | https://anime-crusaders-x.wiki/updates/ |

## Limites da implementação

- O Macro que posiciona, melhora e vende unidades é o sistema nativo do jogo. O yno hub só configura/inicia opções visíveis.
- O script não faz progresso falso, não altera moedas/inventário do servidor e não chama RemoteEvents/RemoteFunctions privados.
- O scanner pode falhar se um patch mudar labels ou estrutura do PlayerGui.
- Unit Hunt PERFECT Assist usa heurísticas visuais, não o estado interno da barra.
- Os verificadores GitHub Actions são estáticos; não substituem um cliente Roblox real.
