# yno hub — Anime Crusaders X

**Versão 2.2.2** · Hub Lua independente para Solara, com organização de abas inspirada em hubs de automação e painel flutuante.

## Instalação rápida

O repositório está público. Dentro de Anime Crusaders X, execute no Solara:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

O loader curto também está em [loadstring.txt](loadstring.txt). O código completo está em [yno.lua](yno.lua).

## Painel

- **Overview** — atalhos rápidos, status e visão geral.
- **Farm Planner** — rotas de Gems, Gold, Event Tokens, Blank Tokens, Trait Remnants, Stat Cubes, Relic Cubes e Curse Tokens.
- **Joiner** — abre Play e a categoria selecionada quando os controles estão visíveis. A escolha de mundo/ato/dificuldade e o Start final continuam no menu do jogo.
- **Game** — Auto Start, Skip Wave, Replay/Retry, Next, habilidades, claims, atalhos Z/N, Auto Sell helpers e início/parada do Smart Macro nativo.
- **Performance** — efeitos locais, sombras, pós-processamento e limite de FPS, com restauração.
- **Summon** — ciclo limitado, tamanho do pull selecionado e parada por texto de alvo novo.
- **Macro** — gravação de cliques/teclas, Loop, import/export JSON e perfis locais.
- **Auto Reroll** — ciclos limitados por tipo e alvo visível.
- **Shop** — compras por botão visível, filtro obrigatório de item e limite.
- **Webhook** — teste e alerta simples de fim de fase, somente para URLs oficiais de webhook do Discord.
- **Minigames** — reentrada em Play Again/Start Minigame e suporte à macro gravada.
- **Misc** — resgate de códigos, claim/train por controles visíveis e UI Scanner.
- **Settings** — escala, salvar configuração, restaurar efeitos, Stop All e Unload.

O painel pode ser arrastado. **RightShift** oculta/mostra; o botão de minimizar deixa um pequeno ícone flutuante **y** para reabrir; **×** descarrega o script.

## Auto Farm: Smart Macro nativo

O botão **Game → Start Auto Farm** abre o Macro nativo e tenta selecionar **Loop**, **This Stage** ou **Routine** e iniciar o modo escolhido.

Configure primeiro o jogo:

1. Entre na fase e abra Macro → Units.
2. Use Fill My Team.
3. Configure os seis slots e Hero: unidade, targeting, Auto upgrade, Auto abilities, limite de posicionamento e ondas.
4. Em Placement, configure Zones ou Recording conforme o mapa.
5. Em Run, escolha Loop para repetir a fase ou Routine para uma fila de tarefas previamente criada.
6. No yno hub, escolha o modo e use Start Auto Farm.

O Smart Macro do jogo faz o posicionamento inteligente, upgrades por slot, venda de farms, foco em chefes e cobertura de inimigos Flying. O hub inicia/para esse sistema, mas não inventa uma estratégia universal para qualquer equipe ou mapa.

### Preset incluído

O código comunitário **AP-RSEHDXU** é o preset Icy para Sword Arena - Raid. Requer Beyond Heaven, Sun God VS Dragon, Mr. Champion, Useless Goddess, Loid e Speedcart. Consulte [docs/sources.md](docs/sources.md), confira seus slots e mapa e importe pelo Macro Catalog ou Macro → Units → Import.

## Como as automações de interface funcionam

As rotinas procuram botões visíveis no PlayerGui e acionam controles do cliente usando APIs documentadas do Solara ou o método nativo GuiButton:Activate. Não chamam RemoteEvents internos, não alteram moedas/inventário no servidor e não tentam contornar anti-cheat.

Alguns recursos são necessariamente parciais:
- Joiner abre a categoria do Play menu; não escolhe por conta própria mundo, ato, dificuldade e Start.
- Summon/Reroll detectam texto visível e contam cliques/tentativas; não recebem confirmação do servidor. Configure banner/tipo/alvo/limite manualmente.
- Shop exige filtro de nome com pelo menos dois caracteres e conta cliques em Buy, não compras confirmadas.
- Auto Re-enter Minigame reabre uma atividade; não joga minigames sozinho.
- A macro gravada registra coordenadas e teclas; não reconhece ondas, mapa, inventário ou estado da partida.

## Validação

- A documentação de funções do Solara foi consultada para GUI, input, clipboard, FPS, filesystem e request.
- O workflow do GitHub Actions tenta validar sintaxe Lua a cada alteração de arquivo Lua.
- **Não é possível executar uma sessão real Roblox/Solara neste ambiente.** Portanto, a integração dinâmica com os rótulos e a hierarquia atuais do PlayerGui ainda precisa de um teste dentro do jogo. Não afirmamos que cada ação foi validada ao vivo.
- O backend proprietário do LixHub é protegido pelo Luarmor. O yno hub é uma implementação independente baseada na lista pública de recursos, não uma cópia do payload fechado.

## Fontes

Consulte [docs/sources.md](docs/sources.md) e a [matriz de recursos](docs/feature-matrix.md).
