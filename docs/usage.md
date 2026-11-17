# Uso do yno hub

## Solara: loader de uma linha

O repositório 6zyloov/yno-hub está público. Dentro de Anime Crusaders X, execute:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

Também é possível abrir yno.lua, copiar tudo e executar diretamente.

## Painel

- **RightShift** — mostrar/ocultar.
- Arraste a janela pela barra superior.
- **×** — fechar a interface.
- **Settings → Stop All** — interromper ciclos e tentar parar o Macro nativo.
- **Settings → Unload** — encerrar o script, desconectar eventos e restaurar efeitos visuais alterados.

## Auto Farm

O yno hub usa o Smart Macro nativo para a automação principal:
1. Entre na fase que quer farmar.
2. Abra Macro → Units → Fill My Team.
3. Configure slots, unidades, targeting, Auto upgrade, Auto abilities, waves e placement.
4. Em Macro → Placement, configure Zones ou Recording para o mapa.
5. Em Macro → Run, selecione Loop para repetir uma fase ou Routine para executar uma fila previamente criada.
6. No yno hub, abra Game, escolha o modo e clique Start Auto Farm.

O botão tenta abrir Macro/Run, escolher o modo e pressionar Start. Se os controles do jogo mudarem ou não estiverem visíveis, o painel informa que essa etapa deve ser concluída manualmente. Stop Auto Farm usa o botão Stop do painel flutuante do jogo.

O Smart Macro nativo é responsável por colocar, atualizar e vender unidades conforme os slots e a estratégia configurados. O yno hub não configura sozinho a equipe completa nem cria uma estratégia ideal sem conhecer seu mapa/time.

## Preset comunitário

O preset **AP-RSEHDXU** (Icy, Sword Arena - Raid) usa:
- Beyond Heaven — P2
- Sun God VS Dragon — P3
- Mr. Champion — P2
- Useless Goddess — P2
- Loid — P1
- Speedcart — P1

Requer essas unidades e bindings compatíveis. Pesquise o código no Macro Catalog ou abra Macro → Units → Import e cole-o.

## Macro de entrada do yno hub

Hotkeys:
- **F6** — iniciar gravação.
- **F7** — parar e finalizar teclas pressionadas.
- **F8** — reproduzir.
- **F9** — interromper reprodução.

A gravação salva cliques em coordenadas relativas à tela e teclas pressionadas/soltas, incluindo a duração. O buffer pode ser salvo em JSON na pasta yno_hub/macros, carregado, importado e exportado. O modo Loop repete até F9.

A macro de entrada não reconhece ondas, unidades ou resultados do jogo. Para posicionamento inteligente e upgrades por onda, use o Smart Macro do Anime Crusaders X.

## Recursos e segurança

- Summon, Reroll e Shop têm limite máximo configurável. Configure o banner, a loja e o custo antes de iniciar.
- O alvo de Summon/Reroll é comparado com textos visíveis antes/depois do ciclo; a detecção depende do resultado ser apresentado na interface.
- Webhook usa apenas URL fornecida por você. A URL não é salva no arquivo de configuração.
- Configurações salvas guardam opções visuais e campos, mas não reativam automações de gasto ao reiniciar.
- Não cole senha, cookie Roblox, token de conta ou token de bot.
- O script não chama RemoteEvents privados, não gera recursos e não altera dados no servidor.

## Diagnóstico

Na aba Misc, use UI Scanner para copiar os nomes/textos dos botões visíveis. Se uma atualização mudar a interface do jogo, isso ajuda a localizar o novo rótulo. A automação só consegue clicar nos controles que estejam visíveis e ativos.

## Estado de validação

O arquivo é validado por sintaxe Lua no GitHub Actions. A API de entrada do Solara foi conferida na documentação. Não foi possível executar uma sessão real do Roblox neste ambiente; por isso, não há alegação de teste ao vivo nem garantia de que cada botão do jogo permaneça com o mesmo nome após patches.
