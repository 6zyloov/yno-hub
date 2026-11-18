# YNO HUB — especificação de paridade com a referência LixHub

**Jogo:** Anime Crusaders X  
**Repositório:** `6zyloov/yno-hub`  
**Referência pública:** [LixHub — Anime Crusaders X](https://robloxscripts.com/script/anime-crusaders-x-lixhub)  
**Data da consulta:** 17/11/2026

Este documento registra os módulos e recursos anunciados publicamente na ficha do LixHub. É uma especificação de referência para orientar uma implementação independente do yno hub. Não significa que todos os recursos já estejam implementados ou testados no yno hub.

## 1. Joiner

### Controles gerais
- Pause Auto Join
- Delay Auto Join

### Modos
- Story
- Legend
- Raid
- Challenge
- Daily Challenge
- Weekly Challenge
- Infinite
- Weekly Tower
- Boss Rush
- Boss Lair
- Events
- Portal
- Infinity Castle
- Tournament
- Infinite Tournament
- Testing Zone

## 2. Join Priority
- Custom Join Priority for All Modes
- Automatically Skip Unavailable Modes

Requisito de implementação: permitir ordenar os modos, tentar o modo mais prioritário disponível e avançar para o próximo quando não houver entrada disponível. O resultado precisa distinguir tentativa enviada de entrada efetivamente confirmada.

## 3. Game

### Fluxo de partida
- Auto Skip Wave
- Auto Start
- Auto Replay
- Auto Next

### Interface e conveniência
- Disable Boss Dialogue
- Hide Ability Cutscenes
- Streamer Mode
- Anti AFK

### Unidades e venda
- Auto Upgrade
- Auto Use Abilities
- Auto Sell Farms
- Auto Sell Farms Wave
- Auto Sell Farms On Last Wave
- Auto Sell Units
- Auto Sell Units Wave
- Auto Sell Units On Last Wave

### Atividades específicas
- Portals
- Escanor Trial
- Kitchen Madness
- Kitchen Card Priorities
- Boss Rush
- Boss Lair

Requisito de implementação: cada regra de venda deve distinguir farms de unidades de combate e oferecer os gatilhos anunciados (em toda onda, onda específica ou última onda), com proteção para não repetir a mesma ação várias vezes na mesma onda.

## 4. Performance

- Low Quality Effects
- Hide Attack Effects
- Hide Attack Animations
- Low Detail Units
- Hide Other Players' Units
- Hide Damage Numbers
- Low Performance Mode
- Black Screen
- Limit FPS
- FPS Limit

Requisito de implementação: alterações visuais locais precisam guardar os valores originais e restaurá-los ao desligar a opção ou descarregar o hub. As duas opções de FPS devem ser preservadas como entradas separadas até que o comportamento original seja confirmado.

## 5. Summon

- Auto Summon
- Select Banner
- Summon Targets
- Summon Rarity Targets
- Unselect If Summoned
- Pull Amount
- Keep Gems
- Keep Anniversary Tickets
- Send Summon Webhooks
- Notify on Rarities
- Notify on Units

Requisito de implementação: banner, alvos, raridades, quantidade por pull e reservas de moedas/tickets precisam ser parâmetros reais da operação. A automação deve parar quando alcançar uma reserva configurada ou quando o alvo for obtido. Notificações só podem afirmar uma unidade/raridade depois de observar o resultado do jogo.

## 6. Macro

- Create Macro
- Record Macro
- Playback Macro
- Delete Macro
- Refresh Macro List
- Playback Mode
- No Ignore Sell Timing
- Export Macro (Copy JSON)
- Import Macro JSON
- Check Macro Units
- Copy Loadout
- Macro Maps

Requisito de implementação: gravação e reprodução devem preservar a ordem e o intervalo temporal das ações, mapear a macro ao mapa/modo correspondente, validar JSON importado, verificar unidades necessárias e permitir cancelar a reprodução. Macro importada não pode executar conteúdo arbitrário de código.

## 7. Auto Reroll

Categorias:
- Trait
- Stat
- Relics
- Curse

Requisito de implementação: cada categoria deve possuir alvo selecionável, critério real de sucesso, limite de tentativas, reserva de recursos e botão de parada. Um campo de texto "Desejado" sem leitura do resultado não constitui reroll automático funcional.

## 8. Shop

Lojas anunciadas:
- Gold Shop
- Event Shop
- Emote Shop
- Babylon Raid Shop
- Cell Raid Shop
- Sakamato Raid Shop
- Shinjuku Raid Shop
- Boss Rush — Control Shop
- Boss Rush — Perfection Shop
- Kitchen Madness Shop
- Einz's Shop

Requisito de implementação: selecionar itens individualmente, verificar custo e saldo, limitar quantidade e confirmar a compra pelo resultado visível do jogo. A automação não deve repetir compras apenas porque uma chamada local não retornou erro.

## 9. Webhook

- Input Webhook
- Input Discord ID (mentions)
- Send on Stage Finished
- Ping on Stage Finished
- Ping on Loss
- More (a ficha pública não especifica os outros eventos)

Requisito de implementação: validar a URL, permitir mensagem de teste, respeitar a opção de menção e enviar eventos reais de conclusão/derrota, não mudanças de onda. Não registrar o URL secreto em logs públicos.

## 10. Requisitos transversais do yno hub

- Interface compacta, consistente e com identidade visual própria.
- Navegação previsível entre módulos.
- Estados ON/OFF sempre sincronizados com a automação real.
- Feedback claro: aguardando, executando, concluído, indisponível ou erro.
- Configurações persistentes, com validação e migração de versões.
- Stop All que realmente cancela todas as rotinas.
- Unload que restaura alterações locais e desconecta eventos.
- Detecção de versão do jogo e diagnóstico de controles ausentes.
- Testes de regressão após mudanças de versão.
- Nenhum controle deve ser apresentado como funcional sem implementação e teste correspondente.

## 11. Referências históricas

Uma listagem antiga do LixHub para o Anime Crusaders original anunciava itens como Auto Lobby, Auto Restart, Select Macro, Equip Macro Units, Copy Macro JSON e Send on Match Finished. São referências históricas de outra publicação; não devem ser tratadas automaticamente como funções confirmadas da ficha atual de Anime Crusaders X.

## 12. Limites da evidência

A listagem pública fornece os nomes dos módulos e controles, mas não revela o código interno do LixHub, os algoritmos privados, as condições exatas de parada nem todos os parâmetros de cada atividade. O painel enviado na publicação tem uma imagem, mas esta consulta não conseguiu validar com precisão cores, dimensões, tipografia ou espaçamentos do painel original. Esses detalhes devem ser confirmados por capturas ou vídeos do painel em funcionamento, nunca inventados.

**Fonte principal:** https://robloxscripts.com/script/anime-crusaders-x-lixhub  
**Referência histórica:** https://scriptblox.com/script/Anime-Crusaders-LixHub-81563
