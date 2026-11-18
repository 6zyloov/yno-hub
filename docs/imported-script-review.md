# Revisão do arquivo enviado — build 1.0.0

**Arquivo de entrada:** `Pasted text(1).txt`  
**Destino avaliado:** `yno.lua`  
**Decisão:** não substituir o script principal por este arquivo sem correções e testes.

O arquivo recebido contém uma proposta baseada em capturar chamadas `RemoteEvent:FireServer`, serializar argumentos, salvar os caminhos e reproduzir chamadas em sessões futuras. Isso é substancialmente diferente do atual yno.lua, que usa controles visíveis do jogo e integrações com UI/Macro. Não foi integrado ao loader principal.

## Bloqueios encontrados na leitura estática

1. **Guard de inicialização suspeito:** `if not game:IsDescendantOf(game) then return end` não valida o PlaceId pretendido. A condição deve ser removida e substituída por uma verificação explícita do jogo alvo.
2. **Escopo da gravação:** o hook de `__namecall` referencia `recording` e `currentMacro` antes de suas declarações locais. Nesse ponto, os nomes referenciados resolvem para globais, não para as variáveis locais declaradas mais adiante; a gravação não observa o estado correto.
3. **Replay duplicado durante aprendizado:** ao capturar um bind, `startLearn` chama `verify`, que chama `fire` novamente. Para ações de compra, summon ou reroll, isso pode repetir a operação e consumir recursos.
4. **Resolução de caminho inconsistente:** `pathOf` pode construir caminhos de remotes que não estão sob ReplicatedStorage, enquanto `byPath` sempre começa em ReplicatedStorage.
5. **Tipo de remote inconsistente:** `byPath` aceita RemoteFunction, mas `fire` e o playback usam `FireServer`, método próprio de RemoteEvent.
6. **Desserialização incompleta:** valores booleanos `false` não são retornados corretamente por `if o.b then`; referências a Instance são reconstituídas com `game:FindFirstChild` usando `GetFullName`, que não é um caminho simples de filho direto.
7. **Macros sem persistência temporal:** os passos são gravados sem os intervalos originais, reproduzidos em intervalo fixo de 0,15 s e mantidos somente na memória. O JSON de macros não é salvo em disco.
8. **Opções sem ligação completa:** os toggles de Auto Next, Auto Skip Wave, Auto Replay, Auto Summon, boss dialogue, cutscenes e Streamer Mode aparecem na UI, mas não estão conectados a uma rotina que os execute no arquivo.
9. **Critério de reroll ausente:** o texto de alvo é armazenado, mas o loop não lê nem compara o resultado com esse alvo; apenas repete até o limite ou a reserva de gems.
10. **Notificação de conclusão incorreta:** `onFinish` envia mensagem sempre que o contador de ondas muda, não quando a partida efetivamente termina.
11. **Desligamento incompleto:** as rotinas em loop são infinitas, não há mecanismo central de cancelamento, e o hook de metamétodo não é restaurado por um Unload.
12. **Persistência frágil:** `writefile("yno/hub.json", ...)` falha quando a pasta `yno` ainda não existe.

## Consequência

Embora o arquivo contenha páginas para Joiner, Jogo, Performance, Summon, Macro, Auto Reroll, Lojas, Webhook e Diagnóstico, a presença dos controles não comprova execução. Alguns controles estão desconectados, e outros podem repetir operações sem validar seu resultado.

## Próxima etapa técnica segura

- Corrigir inicialização, escopo, serialização, persistência e cancelamento.
- Separar captura/diagnóstico de qualquer operação que possa gastar recursos.
- Validar cada recurso no próprio jogo com critérios observáveis e proteção de repetição.
- Marcar recursos não validados como experimentais ou pendentes.
- Manter o arquivo principal anterior até a nova implementação passar nos testes estáticos e de regressão.

Este documento é uma revisão estática do arquivo recebido. Nenhuma execução em Roblox/Solara foi realizada.
