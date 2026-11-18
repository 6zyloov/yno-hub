# yno hub 4.0.2 — guia de uso

## Executar

Abra Anime Crusaders X, conecte o Solara e execute:

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
~~~

O fundo usa assets/yno-background.jpg baixado do próprio repositório e getcustomasset. Se filesystem/custom asset não estiver disponível, o painel continua com fundo escuro.

## Controles do painel

- **RightShift:** mostrar/ocultar.
- **—:** minimizar para o botão flutuante **y**.
- **y:** reabrir.
- Arraste pela barra superior para mover.
- **× / Unload:** fecha o painel, desconecta eventos e restaura efeitos locais.
- Search filtra os controles da página atual.

## Game

A página Game separa **Game** de **Wave Actions**.

- **Auto Vote Start:** procura Vote Start ou Start Match.
- **Auto Skip Waves:** procura Vote Skip ou Skip Wave.
- **Auto Next:** só tenta avançar quando encontra texto de vitória/conclusão.
- **Auto Replay:** só tenta Replay/Retry quando encontra texto de derrota.
- Os botões do lado direito abrem Macro → Units, ou alternam os controles nativos Auto Upgrade, Auto Abilities, Auto Skip Waves, Smart Placement, Auto Start, Auto Replay e Auto Next quando seus rótulos e toggles estão visíveis.

Os toggles de votação e os toggles nativos de Macro são independentes.

## Story Runner

1. Abra **Story**.
2. Selecione um dos 11 mundos, Act 1–6, Normal/Hard, Individual Act/World Skip e Matchmaking/Select Stage.
3. Pressione **Start selected Story**.
4. O runner navega pelos botões que encontra no PlayerGui.
5. Matchmaking termina depois de selecionar Matchmaking; Select Stage procura o botão Start.

World Skip existe nos mundos 1–10 e não em Sword Arena. O modo depende do desbloqueio da sua conta e da tela atual; o script não libera mundos/atos bloqueados.

## Quests

1. Escolha All, Daily, Infinite, Story, Event ou Guide.
2. Pressione **Open selected category**.
3. Use **Claim All** quando a recompensa estiver concluída.
4. Auto Claim observa Claim All nas telas de Quest/Guide/Event/Bounty visíveis.

O jogo é quem registra o progresso. Cinco Daily Quests concluídas liberam Daily Quests Complete! (750 Gems + 10 Trait Remnants). As dez Guide Quests e o claim final liberam Phoenix. Algumas Guide Quests consomem itens/unidades ou exigem ações em partidas; revise antes de gastar recursos.

Bounties exigem três objetivos por cartão; um cartão completo recompensa 5 Event Tokens + 1 Blank Token. Reroll custa 10.000 Gold e apaga o progresso do cartão.

## Smart Macro — farming nativo

1. Entre na fase que deseja farmar.
2. Abra **Macro → Units → Slots** e configure os seis slots + Hero, targeting, Auto upgrade e Auto abilities.
3. Abra **Macro → Units → Placement** e configure Zones, Recording ou Shared area.
4. Em **Macro → Run**, escolha This Stage, Loop ou Routine.
5. Para Routine, crie a fila de tarefas primeiro.
6. No yno hub, use **Start Smart Macro** ou **Pause / Stop Macro**.

O Smart Macro do próprio jogo faz colocação, upgrade, venda e estratégia. O yno hub somente abre/seleciona as opções visíveis e inicia a rotina configurada. Os botões de toggle podem não localizar a opção caso o jogo mude seu texto, layout ou hierarquia.

## Unit Hunt

Requer Player Level 5. Entre por Events → Unit Hunt → Start Hunt.

- **Q:** scan de criaturas raras.
- **E:** começa captura quando o prompt E Capture aparece.
- Na barra, clique, Space ou E quando o marcador entrar na zona; o centro dourado produz PERFECT e dano dobrado.

Auto Hunt procura ProximityPrompts com texto Capture, aproxima o personagem por Humanoid:MoveTo e envia E com intervalo de segurança. O PERFECT Assist tenta reconhecer marker/needle e zona gold/perfect por nomes, geometria e cor. Como a hierarquia da barra pode mudar, deixe Auto PERFECT desligado caso os inputs não coincidam com a barra real.

O Collection Book principal tem 39 entradas; a aba Shinies é separada com 35. As capturas não entram automaticamente no time de Tower Defense. As regiões seguintes abrem em Hunt Wave 3, 6 e 9; No.039 precisa das outras 38 entradas e Hunt Wave 10.

## Rewards

- **Login Rewards:** Daily e Anniversary são resgatadas separadamente. Anniversary Day 1 dá Twenty One + um Anniversary Ticket.
- **Hesia:** fale com Hesia, abra Free Rewards e conclua Join Group, Like + Favorite, Notifications e Follow Event antes de Claim Rewards.
- **YouTube Reward:** inscreva-se em @32xGames, habilite notificações, informe seu próprio nome de canal e use Redeem. A validação é feita pelo jogo.
- **King's Index:** fale com King, abra Open Index e use Claim All nas páginas Normal/Shiny.
- **Blank Units:** Shadow (Atomic) e Lao (Heart) custam 30 Blank Tokens cada.

O hub não faz ações externas de grupo/favorito/seguir/inscrição no seu lugar; ele só auxilia na interface do jogo.

## Performance

- Low Effects desliga sombras e pós-processamento locais.
- Hide Attack Effects desliga ParticleEmitter, Trail, Beam e Highlight locais.
- FPS cap aplica setfpscap.
- Restore performance repõe os estados guardados.

São ajustes de renderização do cliente; não alteram drops nem processamento do servidor.

## Diagnóstico

Em **Settings**:
- **Copy Game UI report:** copia nomes, textos e hierarquia de até 160 controles visíveis do jogo.
- **Run Solara self-check:** lista as APIs de Solara detectadas e ausentes.
- **Save preferences:** guarda escolhas do painel, mas não guarda automações ligadas.
- **Stop All:** desliga toggles, cancela sequências e restaura efeitos.
- **Unload:** encerra o hub.

## Limite de validação

O código passa por compilação Lua 5.4 e testes estáticos de release/wiring. Não foi possível abrir uma sessão ao vivo de Roblox/Solara neste ambiente. Portanto, o teste estático não comprova que todos os nomes/menus atuais serão reconhecidos nem que o PERFECT Assist acerta toda variante da barra.
