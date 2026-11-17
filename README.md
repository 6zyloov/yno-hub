# yno hub — anime crusaders x

Painel companion em Lua, feito para o Solara, com interface dark original e foco em planejamento de farming e configuração do Smart Macro nativo do Anime Crusaders X.

## Arquivos principais

- `yno.lua` — painel completo; não depende de bibliotecas externas.
- `loadstring.txt` — loader remoto de uma linha.
- `docs/usage.md` — instalação e controles.
- `docs/sources.md` — referências, data da consulta e status dos códigos.
- `.github/workflows/lua-check.yml` — validação de sintaxe Lua em pushes e pull requests.

## Instalação no Solara

**O repositório está privado.** Um executor sem autenticação não consegue baixar o arquivo usando o endereço RAW. Para manter o repositório privado, abra `yno.lua`, copie o conteúdo completo e cole no Solara.

Quando você decidir tornar o repositório público, o loader de `loadstring.txt` poderá buscar a versão do GitHub:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
```

Não compartilhe senha, cookie ou token do GitHub com o executor.

## O que o painel entrega

- Dashboard com atalhos e estado do painel.
- Farm Planner para Gems, Gold, Event Tokens, Blank Tokens, Trait Remnants, Stat Cubes, Perfect Stat Cubes, Relic Cubes e Curse Tokens.
- Guia de Smart Macro: This Stage, Loop, Routine, slots, Hero, upgrade priorities, timing, Zones, Recording e Auto Challenge.
- Team Builder com uma formação comunitária de referência e observações sobre cobertura.
- Codes com estado confirmado / não verificado e botão para copiar.
- Patch Notes da atualização consultada em 16 de novembro de 2026.
- Interface com navegação, animações, escala compacta/normal, arrastar, notificações e tecla RightShift para ocultar/mostrar.

## Limites importantes

O yno hub é um **painel companion**, não um autofarm independente. Ele não injeta RemoteEvents, não altera inventário ou moedas, não tenta contornar anti-cheat e não controla o Macro interno. O jogo já oferece Smart Macro com Loop e Routine; as partidas automatizadas precisam ser configuradas e iniciadas no próprio jogo.

Os dados de rotas, times, updates e códigos vêm de guias comunitários independentes. Códigos podem expirar e estratégias dependem da sua equipe, mapa, modo e progresso.

## Fontes

- Macro: https://anime-crusaders-x.wiki/macro/
- Team Building: https://anime-crusaders-x.wiki/team-building/
- Resource Farming: https://anime-crusaders-x.wiki/resource-farming/
- Updates: https://anime-crusaders-x.wiki/updates/
- Codes: https://rblxstat.com/pt/games/7660436108/codes

Consulta feita em 17 de novembro de 2026. Mais detalhes em [docs/sources.md](docs/sources.md).
