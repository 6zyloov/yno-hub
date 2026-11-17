# yno hub — anime crusaders x

**Version 2.0.0** · Hub Lua original com interface inspirada em hubs de automação e foco em Anime Crusaders X.

## Instalação rápida no Solara

O repositório está **público** e o loader remoto está pronto. Dentro de Anime Crusaders X, execute:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

Arquivo principal: [yno.lua](yno.lua) · Instruções: [docs/usage.md](docs/usage.md).

## Abas

- **Overview** — painel e atalhos.
- **Farm Planner** — rotas para Gems, Gold, Event Tokens, Blank Tokens, Trait Remnants, Stat Cubes, Relic Cubes e Curse Tokens.
- **Joiner** — seleção de modo e tentativa de entrar pelo botão visível do lobby.
- **Game** — Auto Start, Skip Wave, Replay/Next, habilidades, claims, Auto Sell helpers, atalhos Z/N e controle do Smart Macro nativo.
- **Performance** — efeitos locais, sombras e limite de FPS.
- **Summon** — ciclo com limite e parada ao detectar um resultado novo configurado.
- **Macro** — gravar/reproduzir cliques e teclas, import/export JSON e perfis locais.
- **Auto Reroll** — ciclos limitados com parada por resultado detectado.
- **Shop** — compra pelo botão visível, com filtro e limite.
- **Webhook** — teste de conexão e alerta básico de fim de fase.
- **Minigames** — reinício por botão visível e suporte à macro gravada.
- **Misc** — resgatar códigos, treinar unidade e UI Scanner.
- **Settings** — escala, salvamento, restauração visual, Stop All e Unload.

## Auto Farm: Smart Macro nativo

O botão **Game → Start Auto Farm** abre o Macro nativo e tenta iniciar o modo escolhido: Loop, This Stage ou Routine.

Antes disso, configure o próprio jogo:
1. Entre na fase pretendida e abra Macro → Units.
2. Use Fill My Team.
3. Configure cada slot: unidade, targeting, Auto upgrade, Auto abilities, placement limit e ondas.
4. Configure Placement → Zones/Recording conforme o mapa.
5. Em Run, escolha Loop ou Routine; para Routine, crie a fila de tarefas antes.
6. No yno hub, selecione o modo e clique Start Auto Farm.

O Smart Macro do jogo faz posicionamento inteligente, upgrades, venda de farms, foco em chefes e cobertura de inimigos Flying. O yno hub inicia e organiza esse sistema; ele não inventa uma estratégia universal para qualquer equipe/mapa.

## Preset de Macro incluído

O código comunitário **AP-RSEHDXU** é o preset de Icy para Sword Arena - Raid. Requer Beyond Heaven, Sun God VS Dragon, Mr. Champion, Useless Goddess, Loid e Speedcart. Confira slots e mapa antes de importar em Macro → Units → Import ou pesquisar no Catalog.

## Como as ações automáticas operam

As ações de cliente procuram controles visíveis em PlayerGui e usam funções de entrada documentadas do Solara. Não chamam RemoteEvents internos, não alteram moedas/inventário no servidor e não tentam contornar anti-cheat. O UI Scanner ajuda a identificar mudanças de texto/controles depois de atualizações do jogo.

## Validação e limites

- O arquivo passa pela checagem automática de sintaxe Lua 5.4 no GitHub Actions.
- A API de entrada, clipboard, FPS e arquivos foi conferida na documentação do Solara.
- **Não foi possível executar o jogo Roblox/Solara neste ambiente**; portanto, a compatibilidade dinâmica com os nomes e hierarquia atuais dos botões ainda precisa ser confirmada em uma sessão real.
- Joiner, Summon, Reroll, Shop, botões de fim de fase e Webhook são baseados na interface visível e podem exigir ajuste se o jogo mudar.
- A macro de entrada grava coordenadas e teclas; não interpreta estado do jogo nem substitui o Smart Macro nativo.
- O backend do LixHub é protegido pelo Luarmor; o yno hub é uma implementação independente inspirada na lista pública de recursos, não uma cópia do código proprietário.

## Fontes

Veja [docs/sources.md](docs/sources.md) e [docs/feature-matrix.md](docs/feature-matrix.md).
