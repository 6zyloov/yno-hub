# Uso do yno hub 3.0.0

## Instalação no Solara

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

O script baixa o fundo do painel em [assets/lixhub-bg.jpg](../assets/lixhub-bg.jpg), grava-o localmente e usa getcustomasset. Se o download/asset local não estiver disponível no executor, o painel abre com fundo escuro simples.

## Controles do painel

- **RightShift** — mostrar/ocultar.
- **—** — minimizar para o botão flutuante **y**.
- Clique em **y** para reabrir.
- Arraste pela barra superior.
- **×** — Unload, encerra os loops, desconecta eventos e restaura efeitos locais.
- A caixa Search filtra os cartões da página atual.

## Missions

1. Abra Missions.
2. Escolha All, Daily, Infinite, Story, Event ou Guide.
3. Pressione Open selected category.
4. Pressione Claim All rewards para reivindicar o que estiver concluído.
5. Auto claim pode ficar ligado enquanto a tela de Quest/Event Quest estiver aberta.

O script não cria progresso de quest por conta própria. Os objetivos são completados no modo de jogo correspondente e depois podem ser coletados pelo painel.

### Phoenix / Guidebook

Abra Guidebook → complete as 10 Guide Quests → Claim All / Guide Quests Complete!. A recompensa final é Phoenix. Algumas tarefas exigem consumir XP Food, unidades ou Stat Cubes; faça essas escolhas conscientemente no jogo.

### Bounties

Fale com Navi, indicado como Missions, no Request Board. Abra Bounties, conclua os três objetivos de um cartão e colete 5 Event Tokens + 1 Blank Token. Reroll custa 10.000 Gold e descarta o progresso atual daquele cartão.

## Story Runner

1. Abra Story.
2. Escolha mundo, Act 1–6, Normal/Hard, Individual Act/World Skip e Matchmaking/Select Stage.
3. Pressione Start Story.
4. Ative Auto Start, Auto Skip e Auto Next conforme a estratégia.
5. Para Auto Farm com colocação/upgrades/venda de unidades, configure Macro → Units e Placement primeiro e inicie o Smart Macro.

World Skip é Normal-only, aplica +900% HP e existe nos mundos 1–10; Sword Arena não oferece World Skip. O botão Auto Next segue apenas o próximo estágio que o próprio jogo disponibilizar; não desbloqueia mundos ou requisitos automaticamente.

## Unit Hunt

1. Seu jogador precisa estar no Level 5.
2. Abra Unit Hunt → Start Hunt.
3. Ative Auto Hunt para procurar ProximityPrompts de captura, aproximar o personagem e usar E.
4. O script pressiona Q de tempos em tempos para scan.
5. Durante o minigame, o assist tenta identificar marker/needle e gold/perfect zone pelos nomes dos elementos de UI; se não reconhecer a barra, acerte manualmente o centro dourado com clique, Space ou E.

A barra pode mudar depois de um patch. O assist não adivinha coordenadas nem promete PERFECT em toda captura. Book registra 39 capturas distintas; Shinies tem uma coleção separada de 35 entradas. Capturas de Unit Hunt não se tornam automaticamente unidades equipáveis de Tower Defense.

## Free Units

- Phoenix: 10 Guide Quests + reivindicar Guide Quests Complete!.
- Shadow (Atomic): custa 30 Blank Tokens.
- Lao (Heart): custa 30 Blank Tokens.

O claim de Blank Unit só é iniciado pelo botão explícito na aba Free Units. Confira saldo e limite de resgate antes de clicar.

## Smart Macro

Configure o jogo antes de iniciar:
1. Macro → Units → Fill My Team.
2. Configure os seis slots + Hero, Targeting, Auto upgrade, Auto abilities, Placement limit e waves.
3. Macro → Placement → Zones ou Recording.
4. Macro → Run → Loop, This Stage ou Routine.
5. Em Routine, crie a fila de tarefas em Macro → Routine antes de iniciar.
6. Abra a aba Macro do yno hub e pressione Start Smart Macro.

O Macro nativo realiza posicionamento, upgrades e venda inteligentes conforme a equipe e o mapa. O yno hub apenas abre/seleciona controles visíveis e inicia/para o sistema configurado.

## Performance

Low Effects desativa sombras e pós-processamento local. Hide Attack Effects desativa ParticleEmitter, Trail, Beam e Highlight locais. Os valores anteriores são restaurados por Restore performance ou Unload. FPS cap usa setfpscap e tenta restaurar o valor inicial.

## Diagnóstico

A automação só clica controles visíveis e ativos. Patches podem alterar nomes, hierarquia ou menus. O Story Runner pausa com um aviso se não encontrar um controle; o Unit Hunt pode continuar dependendo do timing manual se não conseguir identificar a barra.
