# yno hub — anime crusaders x

Script hub Lua original para Anime Crusaders X, com interface no estilo de um hub de automação, abas completas e ferramentas client-side.

## Instalação no Solara

O repositório está privado. Um executor sem autenticação não consegue buscar o arquivo RAW. Para usar sem publicar o repositório:
1. Abra [yno.lua](yno.lua).
2. Copie o conteúdo completo.
3. Cole no Solara e execute dentro de Anime Crusaders X.
4. RightShift mostra/oculta o painel.

O loader de uma linha em [loadstring.txt](loadstring.txt) só funciona quando o repositório for público:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
```

## Abas

- Joiner — modo e repetição de seleção de menu.
- Game — Start, Skip Wave, Replay, Next, habilidades, claims e assistência de Auto Upgrade.
- Performance — baixa qualidade local, ocultação de efeitos e limite de FPS.
- Summon — ciclo limitado com alvo de parada e número máximo.
- Macro — gravação e reprodução de cliques/teclas, JSON, perfis locais e hotkeys F6–F9.
- Auto Reroll — ciclos limitados e parada por resultado.
- Shop — compras limitadas com filtro de item.
- Webhook — notificação de teste via webhook fornecido pelo usuário e alerta de fim de fase.
- Minigames — reentrada por botões visíveis e suporte a macro gravada.
- Misc — resgatar código, claim, train e UI Scanner.
- Settings — salvar configuração, escala, restaurar visuais, parar e descarregar.

## Como a automação opera

O hub usa botões e textos visíveis no PlayerGui. Isso evita inventar RemoteEvents ou chamar APIs privadas desconhecidas. O nome e a hierarquia dos controles do jogo podem mudar em atualizações; a aba Misc inclui um UI Scanner para diagnosticar controles visíveis.

O Macro nativo do jogo continua sendo a opção mais robusta para posicionamento inteligente, upgrades por onda, venda de farm, rotinas, gravações por mapa e execução contínua. O yno hub inclui atalhos e macro de entradas para completar esse fluxo.

## Fontes consultadas em 17/11/2026

- LixHub feature inventory: https://robloxscripts.com/script/anime-crusaders-x-lixhub
- LixHub listing: https://www.rblxscripts.net/scripts/lixhub-anime-crusaders-x-4b2d1732
- Game Macro: https://anime-crusaders-x.wiki/macro/
- Macro Presets: https://anime-crusaders-x.wiki/macro-presets/
- Settings & Controls: https://anime-crusaders-x.wiki/settings/
- Updates: https://anime-crusaders-x.wiki/updates/
- Resource Farming: https://anime-crusaders-x.wiki/resource-farming/

## Limitações

Este script não foi executado em uma sessão real de Roblox/Solara neste ambiente. As rotinas de interface precisam ser verificadas contra os controles visíveis no seu cliente. A gravação e reprodução exigem que o executor permita VirtualInputManager; leitura/gravação JSON exigem as funções de arquivo do executor.

Não há código-fonte aberto do backend do LixHub: o loader público encaminha para o sistema Luarmor, e seu key system está ofuscado. O yno hub é uma implementação própria inspirada na organização e na lista pública de funcionalidades, não uma cópia do código proprietário.
