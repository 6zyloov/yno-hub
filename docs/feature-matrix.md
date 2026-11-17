# yno hub — matriz de recursos

**Build 2.2.1 · 17 de novembro de 2026**

Esta matriz separa automação real de interface, recursos delegados ao jogo e áreas experimentais.

| Área anunciada por hubs | Estado no yno hub | Funcionamento e limite |
|---|---|---|
| Joiner | Parcial | Abre Play e tenta abrir a categoria selecionada quando o botão está visível. Não escolhe automaticamente mundo, ato, dificuldade e Start. |
| Auto Start / Skip / Replay / Next | UI | Procura e clica controles visíveis de início, skip, replay/retry e next. Auto Start só considera Vote Start / Start Match para evitar um botão Start genérico. |
| Auto Upgrade | Nativo + atalhos | Z alterna prioridades P1–P6/Off; N executa Auto instantâneo. Smart Macro controla upgrades por slot. |
| Auto Place / Auto Sell / boss targeting / Flying | Smart Macro nativo | O Smart Macro do jogo faz essas ações conforme os slots, zonas e a estratégia configurados. |
| Auto Abilities | Nativo + UI | Configure Settings → Units ou Macro → Units por slot; o hub também pode acionar botões de habilidade visíveis. |
| Summon | Experimental UI | Procura o botão X1/X10 correspondente, respeita o limite e tenta parar por um texto-alvo novo. Conta cliques, não confirma pulls com o servidor. |
| Auto Reroll | Experimental UI | Clica no Reroll visível no painel do tipo selecionado, conta tentativas e tenta detectar um resultado novo na interface. |
| Shop | Experimental UI | Exige filtro de item e procura Buy na mesma seção; respeita limite de cliques, não compras confirmadas. |
| Macro | Implementado no cliente | Grava/reproduz cliques e teclas com duração, Loop, JSON local e perfis. Não tem reconhecimento de estado do jogo. |
| Macro Catalog preset | Guia + código | Inclui AP-RSEHDXU para Sword Arena - Raid. A importação ocorre no Macro do jogo. |
| Webhook | Parcial | Teste e aviso básico de fim de fase, somente para URLs oficiais Discord. Não reproduz todos os webhooks do LixHub. |
| Minigames | Parcial | Tenta reentrar em Play Again/Start Minigame e permite usar macros gravadas; não resolve minigames sozinho. |
| Codes / Rewards / Training | UI | Preenche campo de código ou clica Claim/Train quando controles esperados estão visíveis. |
| Performance | Client-side | FPS cap, sombras, pós-processamento e efeitos locais; tenta restaurar estado ao desligar ou descarregar. |
| Floating window | Implementado | Janela arrastável, minimizar para ícone flutuante y, reabrir pelo ícone ou RightShift, unload em ×. |

## Regras de funcionamento

- Botões dependem dos nomes/textos e da hierarquia atuais do PlayerGui; patches podem exigir ajuste.
- Summon, Reroll e Shop são baseados em cliques de UI. O servidor pode rejeitar uma ação; o contador não representa recompensa confirmada.
- A detecção de alvo depende de texto visível novo e não lê o inventário interno do servidor.
- Nenhuma função cria recursos, altera inventário/moeda, chama RemoteEvents privados ou tenta contornar anti-cheat.
- O Auto Farm principal é o Smart Macro nativo, configurado por você de acordo com equipe e mapa.
- O código passa pelo workflow de sintaxe Lua do GitHub Actions se a execução do job for concluída com sucesso; não foi testado em sessão viva Roblox/Solara neste ambiente.
