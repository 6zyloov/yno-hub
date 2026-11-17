# Uso do yno hub 3.0.1

## Instalação no Solara

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

O script baixa o wallpaper em [assets/lixhub-bg.jpg](../assets/lixhub-bg.jpg), grava no filesystem do executor e usa getcustomasset. Sem esse suporte, o painel abre com fundo escuro simples.

## Controles

- **RightShift** — mostrar/ocultar.
- **—** — minimizar para o botão flutuante **y**.
- Clique em **y** para reabrir.
- Arraste pela barra superior.
- **×** — Unload, encerra loops, desconecta eventos e restaura efeitos locais.
- Search filtra os cartões da página atual.

## Missions

1. Abra Missions.
2. Selecione All, Daily, Infinite, Story, Event ou Guide.
3. Pressione Open selected category e Claim All rewards.
4. Auto claim pode ficar ligado enquanto a tela de Quest/Event Quest estiver aberta.
5. Start Story quest grind liga Auto Start/Skip/Next e inicia o Story selecionado.
6. Open Challenges abre Play → Challenges. Start Auto Challenge Routine inicia Macro → Routine depois de você configurar Macro → Dailies → Auto Challenge.

O script coleta objetivos concluídos; o progresso vem das partidas e tarefas que o jogo atribuiu. Daily Quests Complete! exige cinco tarefas e dá 750 Gems + 10 Trait Remnants.

### Guidebook / Phoenix

Abra Guidebook → complete as 10 Guide Quests → Claim All / Guide Quests Complete!. A recompensa é Phoenix. Algumas tarefas exigem consumir XP Food, unidades, Trait Remnants ou Stat Cubes.

### Bounties

Fale com Navi/Missions no Request Board. Abra Bounties, conclua os três objetivos do cartão e reivindique 5 Event Tokens + 1 Blank Token. Reroll custa 10.000 Gold e apaga o progresso atual do cartão.

## Story Runner

1. Abra Story.
2. Escolha mundo, Act 1–6, Normal/Hard, Individual Act/World Skip e Matchmaking/Select Stage.
3. Pressione Start Story.
4. Ligue Auto Start, Auto Skip, Auto Next e, se quiser, Auto Retry.
5. Auto Next só avança quando a UI indica vitória/conclusão; Auto Retry só age depois de derrota.

World Skip é Normal-only, +900% HP, mundos 1–10; Sword Arena não oferece World Skip. Auto Next segue o próximo estágio que o jogo disponibilizar e não desbloqueia mundos/atos.

## Unit Hunt

1. Requer Player Level 5.
2. Abra Events → Unit Hunt → Start Hunt.
3. Ative Auto Hunt: procura ProximityPrompts Capture, aproxima o personagem e usa E.
4. Q faz scan periódico para localizar raros.
5. A assistência de captura tenta identificar marker/needle e gold/perfect zone por nome, geometria e cor. Se não reconhecer, acerte manualmente o centro dourado com clique, Space ou E.

Book tem 39 entradas; Shinies tem 35 entradas separadas. As capturas não viram unidades equipáveis de Tower Defense. São quatro regiões, com desbloqueios em Hunt Wave 3, 6 e 9, e No.039 exige 38 entradas + Hunt Wave 10 + Sky Altar.

## Free Units & Rewards

- **Twenty One:** claim no Anniversary Login, Day 1. Use Claim Login Rewards para verificar Daily e Anniversary separadamente.
- **Phoenix:** 10 Guide Quests + Claim Guide Quests Complete!.
- **Hesia:** o painel tem Join Group, Like + Favorite, Enable Notifications e Follow Event. Conclua as quatro tarefas e use Claim Hesia Rewards.
- **YouTube Reward:** subscreva @32xGames, ative notificações, digite seu próprio nome de canal no campo YouTube channel name e pressione Redeem YouTube Reward. A verificação continua sendo feita pelo jogo.
- **King's Index:** Claim All recolhe recompensas de unidades Normal/Shiny registradas.
- **Shadow (Atomic)/Lao (Heart):** 30 Blank Tokens cada. Use Claim Selected Blank Unit somente depois de conferir saldo.

## Golden Crusader / Anniversary Hunt

Golden Crusader é um inimigo permanente, com chance base de 1 em 5.000.000 por inimigo normal fora do Testing Zone; Weekend Frenzy melhora a chance para 1 em 3.333.333. Derrote-o para receber um token de uso único. Abra Items → Crusader Token → Use; o token concede 250.000 Gems e Trait Remnants. Anniversary Hunt é outro evento de drops enquanto estiver ativo.

## Smart Macro

1. Macro → Units → Fill My Team.
2. Configure seis slots + Hero, targeting, Auto upgrade, Auto abilities, Placement limit e waves.
3. Macro → Placement → Zones ou Recording.
4. Macro → Run → Loop, This Stage ou Routine.
5. Em Routine, crie a fila de tarefas antes de iniciar.
6. Na aba Macro do yno hub, pressione Start Smart Macro.

O Macro nativo faz posicionamento, upgrades, habilidades e venda conforme slots e zonas. O yno hub abre/seleciona controles visíveis e inicia/para o sistema configurado.

## Performance

Low Effects desativa sombras e pós-processamento local. Hide Attack Effects desativa ParticleEmitter, Trail, Beam e Highlight locais. Restore performance/Unload restaura os valores anteriores. FPS cap usa setfpscap e tenta restaurar o valor inicial.

## Diagnóstico

A automação só age em controles visíveis e ativos. Patches podem alterar nomes/hierarquia. O Story Runner pausa com aviso se não encontrar um controle; o Unit Hunt pode depender do timing manual se a barra deixar de ser reconhecida.
