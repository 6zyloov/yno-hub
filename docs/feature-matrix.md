# yno hub — matriz de recursos

Este documento separa o que o hub executa diretamente, o que delega ao Smart Macro do jogo e o que ainda depende de validação ao vivo.

| Área anunciada por hubs | yno hub | Como funciona / limite |
|---|---|---|
| Joiner | Parcial | Seleciona um modo e procura o botão visível. Não implementa ainda uma fila inteligente por prioridade/rotação de modos. |
| Auto Start / Skip / Replay / Next | UI | Clica em controles visíveis; Auto Retry, Auto Next e Auto Vote Start também existem em Settings do próprio jogo. |
| Auto Upgrade | Nativo + atalhos | Z alterna P1–P6/Off; N executa Auto instantâneo. Smart Macro configura Auto upgrade por slot. |
| Auto Place / Auto Sell / Boss targeting / Flying | Smart Macro nativo | O Smart Macro cuida dessas ações de acordo com os slots e estratégia configurados. |
| Auto Abilities | Nativo + UI | Configure Settings → Units ou Macro → Units por slot; o hub também pode acionar botões de ability visíveis. |
| Summon | Experimental UI | Clica no botão Summon, respeita limite e tenta parar quando um texto novo com o alvo aparece. Não lê resultados internos do servidor. |
| Auto Reroll | Experimental UI | Clica no Reroll visível no painel do tipo escolhido, conta tentativas e busca um resultado novo na interface. |
| Shop | Experimental UI | Procura botão Buy junto do item configurado e respeita limite de compras. Confirme estoque e moeda. |
| Macro | Implementado no cliente | Grava/reproduz cliques e teclas, incluindo duração, com JSON local. Não tem reconhecimento de estado do jogo. |
| Macro Catalog preset | Guia + código | Inclui AP-RSEHDXU, preset Icy para Sword Arena - Raid. Importação ocorre no Macro do jogo. |
| Webhook | Parcial | Teste de endpoint e aviso simples quando a UI mostra vitória/derrota/fim de fase. Não reproduz todos os webhooks do LixHub. |
| Minigames | Parcial | Tenta reentrar por botões visíveis e permite macros de entrada gravadas; não resolve minigames por visão/IA. |
| Codes / Rewards / Training | UI | Preenche campo de código, clica Redeem/Claim/Train quando os controles esperados estiverem visíveis. |
| Performance | Client-side | Limita FPS e reduz sombras, pós-processamento e efeitos locais. Restaura estado ao desativar/descarregar. |

## Regras de funcionamento

- Os botões dependem dos nomes/textos e da hierarquia atuais do PlayerGui. Patches podem exigir ajuste.
- Ciclos de Summon, Reroll e Shop têm limites; isso não garante que o servidor aceite cada operação.
- Nenhuma função cria recursos, altera inventário ou moeda, ou executa RemoteEvents privados.
- O Auto Farm principal é o Smart Macro nativo, que você precisa configurar de acordo com a equipe e o mapa.
- O código passa pela checagem de sintaxe Lua 5.4 no GitHub Actions, mas não foi testado em sessão viva de Roblox/Solara neste ambiente.
