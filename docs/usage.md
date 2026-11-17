# Uso do yno hub

## Solara

1. Baixe o arquivo `yno.lua` deste repositório.
2. Abra o arquivo e copie o conteúdo completo.
3. Cole no editor do Solara e execute durante o jogo.
4. Pressione **RightShift** para mostrar ou ocultar o painel.

## Loader de uma linha

O arquivo `loadstring.txt` contém o loader remoto. Ele só funciona quando o repositório está público, pois o Solara não tem como autenticar em um repositório privado:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/6zyloov/yno-hub/main/yno.lua"))()
```

Não coloque tokens do GitHub dentro do script. Para manter o repositório privado, use o conteúdo de `yno.lua` localmente.

## O que o painel faz

- Organiza rotas e recompensas.
- Explica o Smart Macro nativo: Loop, Routine, slots, prioridades, zonas e gravações.
- Mostra códigos recentes e permite copiar cada código.
- Mostra uma formação comunitária de referência.
- Resume atualizações recentes.

**O que não faz:** não é um autofarm independente; não invoca eventos remotos não documentados, não gera recursos, não joga partidas por você e não contorna anti-cheat. O Macro do próprio jogo continua responsável pela automação de partidas.

## Atalhos

- `RightShift`: mostrar/ocultar.
- Arraste o painel pela barra superior.
- `×`: fechar.
- Settings: escala compacta ou normal.
