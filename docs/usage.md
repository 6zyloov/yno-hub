# Uso do yno hub

## Loader do Solara

O repositório 6zyloov/yno-hub está público. Dentro de Anime Crusaders X, execute:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

Também é possível abrir [yno.lua](../yno.lua), copiar o arquivo inteiro e executar diretamente.

## Janela flutuante

- **RightShift** — mostrar/ocultar a janela.
- **—** na barra superior — minimizar para o pequeno botão flutuante **y**.
- Clique no botão **y** para reabrir.
- Arraste a janela pela barra superior.
- **×** — descarregar o yno hub, interromper os ciclos e restaurar os efeitos locais/FPS alterados.
- Fechar somente o editor do Solara não deveria fechar a GUI, pois ela é parentada ao container do executor. O script precisa continuar ativo no cliente Roblox.

## Auto Farm com Smart Macro

O jogo fornece o sistema de automação principal. Para configurar:

1. Entre na fase desejada e abra Macro → Units → Fill My Team.
2. Configure os seis slots e Hero, inclusive targeting, Auto upgrade, Auto abilities, placement limit e ondas.
3. Em Macro → Placement, configure Zones ou Recording para o mapa.
4. Em Macro → Run, selecione Loop para repetir a fase atual ou Routine para executar uma fila de tarefas criada previamente.
5. No yno hub, abra Game, escolha Loop, This Stage ou Routine e pressione Start Auto Farm.
6. Use Stop Auto Farm para acionar Stop/Pause do painel Macro nativo.

O botão Start tenta encontrar Macro → Run, selecionar o modo e pressionar Start. Caso o layout do jogo mude ou o controle não esteja visível, faça essa etapa manualmente. O posicionamento, upgrades e venda inteligentes são feitos pelo Macro nativo, de acordo com sua configuração.

## Joiner

Abra a aba Joiner, escolha uma categoria e pressione Open Mode. O hub pode abrir Play e o botão visível da categoria escolhida. Depois, selecione o mundo, ato, dificuldade e Matchmaking/Select Stage no jogo e confirme Start. Auto Open Selected Mode executa apenas a abertura da categoria quando ela está visível; não finge completar toda a seleção de partida.

## Summon, Reroll e Shop

- Configure banner/tipo, nome de alvo e limite antes de ligar ciclos.
- Summon procura o botão correspondente ao tamanho de pull escolhido; não clica em um botão genérico se o botão X1/X10 não aparecer.
- O contador registra tentativas de clique, não pulls confirmados pelo servidor.
- Alvos são detectados por textos novos na interface. Se o jogo substituir o texto de uma label sem criar um novo item visível, a detecção pode não perceber.
- Shop exige um filtro de item com pelo menos dois caracteres. O contador registra cliques no botão Buy, não compras confirmadas. Confira moeda, estoque e quantidade.
- Use Stop para interromper cada ciclo. Settings → Stop All interrompe todos os ciclos.

## Macro de entrada

Hotkeys:
- **F6** — iniciar gravação.
- **F7** — parar e finalizar teclas pressionadas.
- **F8** — reproduzir.
- **F9** — interromper reprodução.

A gravação captura cliques em coordenadas relativas à tela e teclas pressionadas/soltas, incluindo sua duração. O buffer pode ser salvo em JSON em yno_hub/macros, carregado, importado e exportado. O modo Loop repete até F9.

Essa macro não reconhece ondas, unidades ou resultados. Para posicionamento inteligente e upgrades por onda, use o Smart Macro nativo.

## Webhook

O endpoint é opcional e permanece apenas na sessão. Por segurança, o hub aceita somente endereços HTTPS de webhook do Discord nos domínios discord.com/api/webhooks ou discordapp.com/api/webhooks. Não cole token de bot, senha, cookie Roblox ou token de conta.

## Performance

Low Quality Effects desativa sombras globais e pós-processamento local. Hide Attack Effects desativa partículas, trails, beams e highlights. Os valores anteriores são guardados para restauração. O FPS cap original também é restaurado em Unload quando getfpscap estiver disponível.

## Diagnóstico

Na aba Misc, use UI Scanner para listar os botões visíveis. Se uma atualização mudar a interface do jogo, isso ajuda a localizar novos rótulos. A automação só clica controles visíveis e ativos.

## Limites de validação

O código passa pelo workflow de sintaxe Lua do GitHub Actions quando a verificação termina com sucesso. A API do Solara foi conferida na documentação. Não foi possível executar uma sessão Roblox/Solara ao vivo neste ambiente; por isso, não afirmamos teste real de cada botão ou automação no jogo.
