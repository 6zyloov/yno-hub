# yno hub — anime crusaders x

Painel companion em Lua para organizar farming e acelerar a configuração do **Macro nativo** de Anime Crusaders X.

> O yno hub não injeta RemoteEvents, não altera moedas e não tenta contornar o anti-cheat. O farming automatizado fica a cargo do Smart Macro que já existe no jogo. O painel reúne rotas, presets de configuração, prioridades, códigos e notas de atualização.

## Instalação

O repositório está privado no momento. O `loadstring` remoto só poderá buscar o arquivo no GitHub quando o repositório for público. Não coloque token ou senha dentro do script.

Depois de tornar o repositório público, use no Solara:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
```

Alternativamente, abra `yno.lua`, copie o conteúdo completo e execute localmente pelo seu executor. O script não baixa bibliotecas externas.

## O que existe no painel

- Dashboard com estado da sessão e atalhos.
- Farm Planner para Gems, Gold, Event Tokens, Blank Tokens, Trait Remnants, Stat Cubes, Relic Cubes e Curse Tokens.
- Macro Guide com configuração de seis unidades + Hero, posicionamento, prioridades, timing, Loop, Routine e Auto Challenge.
- Team Planner com uma composição comunitária de referência; exige que você possua as unidades.
- Códigos reportados como ativos em 17 nov 2026, com aviso de confirmação no jogo.
- Resumo das atualizações de 16 nov 2026.
- Janela arrastável, páginas, notificações, copiar instruções e tecla RightShift para mostrar/ocultar.

## Limites honestos

O script é um painel de apoio, não um autofarm independente. A automação real deve ser iniciada no Macro do jogo. Não há API pública documentada para o painel externo controlar o Macro, ler inventário ou concluir missões diretamente; por isso, o yno hub não promete isso e não tenta adivinhar RemoteEvents. A configuração de unidade e o sucesso das rotas dependem da equipe, mapa, modo e progresso da conta.

## Fontes consultadas

- Macro nativo e configuração: https://anime-crusaders-x.wiki/macro/
- Equipes e sinergias: https://anime-crusaders-x.wiki/team-building/
- Rotas de recursos: https://anime-crusaders-x.wiki/resource-farming/
- Atualizações: https://anime-crusaders-x.wiki/updates/
- Códigos: https://rblxstat.com/pt/games/7660436108/codes

As páginas acima são guias comunitários independentes, não documentação oficial da equipe do jogo. Códigos e rotas podem mudar sem aviso.

## Arquivos

- `yno.lua` — painel completo.
- `loadstring.txt` — loader de uma linha para quando o repositório estiver público.

## Versão

`1.0.0` — 17 nov 2026.
