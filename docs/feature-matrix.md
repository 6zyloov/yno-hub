# yno hub 4.0.3 — matriz de recursos

| Área | Estado | Comportamento |
|---|---|---|
| Interface | Implementado no código | Sidebar, nove páginas, tema dark slate-blue, imagem de fundo, linhas compactas, Game/Wave Actions em duas colunas, search, drag, RightShift, minimize/floating y e Unload. |
| UI scanner | Implementado no código | Varre botões ativos do PlayerGui; ranqueia texto, nome, contexto, área e ZIndex; permite contexto estrito para telas sensíveis; relatório copiável. |
| Input Solara | Implementado no código | mousemoveabs + mouse1press/mouse1release, mouse1click fallback, GuiButton:Activate fallback; keyclick para teclas. |
| Story | UI automation | Play → Story → World → Act/World Skip → Difficulty → Matchmaking/Select Stage → Start, se os controles estiverem presentes. |
| Auto Vote Start / Skip | UI automation | Clica nos controles visíveis Vote Start/Start Match e Vote Skip/Skip Wave em intervalo limitado. |
| Auto Next / Replay | Heurística de UI | Procura texto de vitória/derrota e clica Next/Replay; depende dos textos da tela atual. |
| Quests | UI automation | Abre All/Daily/Infinite/Story/Event/Guide e procura Claim All; auto claim observa Quest/Guide/Event/Bounty. |
| Smart Macro | Integração nativa | Abre Macro, Run, seleciona This Stage/Loop/Routine, inicia; pausa/stop e expõe toggles nativos quando a UI corresponde. |
| Unit Hunt | Experimental | Q scan, captura por ProximityPrompt + E, aproximação local; PERFECT Assist heurístico. |
| Login Rewards | UI helper | Tenta resgatar Daily e Anniversary separadamente, reabrindo a janela entre tracks. |
| Hesia / YouTube / Index | UI helper | Claim em Hesia, campo e Redeem YouTube, King's Index Claim All; requisitos sociais/externos continuam manuais. |
| Blank Units | UI helper | Abre Blank Tokens e seleciona Shadow (Atomic)/Lao (Heart); custo de 30 tokens cada. |
| Performance | Client-side | Low Effects, Hide Attack Effects, FPS cap e restauração dos estados locais. |
| Settings | Implementado no código | Self-check, relatório de UI, save preferences, Stop All, Unload. |

## Testes automáticos

GitHub Actions executa:
- luac5.4 -p yno.lua;
- luac5.4 -p scripts/static-check.lua;
- lua5.4 scripts/static-check.lua yno.lua.

Os testes verificam sintaxe, módulos obrigatórios, nomes de função duplicados, versão, helper de toggle e ausência de invocação remota privada.

## O que ainda não está provado

**Nenhuma partida Roblox/Solara foi executada dentro deste ambiente de desenvolvimento.** A automação visual depende do texto e da hierarquia reais do PlayerGui no seu cliente. Auto Next/Replay dependem dos indicadores de resultado. O PERFECT Assist é experimental. A matriz não chama esses pontos de runtime-certified.
