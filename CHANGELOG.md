# Changelog — yno hub

## 4.0.2 — 17 November 2026

- Reconstrução completa do script com nove módulos e layout compacto próprio inspirado na organização LixHub.
- Game e Wave Actions em duas colunas.
- Scanner de UI por correspondência, contexto, tamanho e hierarquia; contexto estrito para Macro/Run e claims sensíveis.
- Input Solara documentado: mousemoveabs, mouse1press, mouse1release, mouse1click e keyclick.
- Integração explícita ao Smart Macro nativo: This Stage, Loop, Routine, Pause/Stop, Auto Upgrade, Auto Abilities, Auto Skip Waves, Smart Placement, Auto Start, Auto Replay e Auto Next.
- Story runner com cancelamento por generation token.
- Quests, Login Rewards Daily/Anniversary, Hesia, YouTube Reward, King's Index, Blank Tokens e Unit Hunt helpers.
- Stop All restaura performance local, desliga toggles e tenta pausar o Macro nativo.
- Self-check e Copy Game UI report.
- CI ampliado para sintaxe Lua 5.4 e static wiring checks.

## 4.0.1

- Correção da passagem de generation token para Macro.
- Toggle de opções nativas deixou de fingir que podia garantir o estado ON; os botões foram nomeados como Toggle.
- Login Rewards passou a reabrir a janela entre Daily e Anniversary.

## 4.0.0

- Base reescrita do zero depois do antigo painel genérico.
- Novo modelo de módulos, scanner de controles, UI compacta e ações com retorno explícito.

## Validação

A sintaxe e os checks estáticos passam no GitHub Actions quando o último run estiver concluído. **Nenhum teste ao vivo no cliente Roblox/Solara foi executado neste ambiente.** Não confundir uma verificação estática aprovada com garantia de que cada botão do jogo atual será detectado.
