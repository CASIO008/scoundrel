# Tradução Completa Adicionada

A aplicação foi inteiramente adaptada para comportar os 3 idiomas solicitados (Inglês, Português, Chinês Simplificado).

## Mudanças Realizadas
- **Dicionário de Tradução**: Construí uma estrutura local baseada no `i18n` que contém a tradução exata e contextual para TODAS as strings visuais da interface (menus, textos de ataque, escudo, boot/terminal inicial e textos de vitória/derrota).
- **Opção de Idioma Inserida**: A navegação do menu de *Settings* passou a ter 7 itens (ao invés de 6). A nova **Opção 6** agora se chama `LANGUAGE / IDIOMA / 语言`. Usando as setas para esquerda e direita é possível transitar entre os três.
- **Adaptação de Fontes (Chinês)**: Toda vez que o idioma Chinês (`zh`) é selecionado, a engine recarrega automaticamente todas as 11 fontes da interface mapeando-as para a fonte **Microsoft YaHei**. Quando é selecionado Português ou Inglês, as fontes originais (ex: `Fifties Movies.ttf`, `Gothik Steel.ttf`) são carregadas imediatamente.
- **Salvamento de Estado**: O idioma selecionado foi integrado ao arquivo local de save (`privy_save.lua`). Se você mudar o jogo pro Chinês e fechar o app, ao reabrir ele lembrará do idioma escolhido.

## Como Testar
1. Inicie a aplicação no Love2D
2. Vá em **Settings**.
3. Desça até a opção "IDIOMA: PT" (Opção 6).
4. Utilize a seta para a **direita** ou **esquerda** (ou A / D) para alternar o idioma para **Chinês** ou **Inglês** e perceba que toda a UI responde instantaneamente.
5. Inicie a partida para testar o sistema in-game (menus de popup dos inimigos, terminal, vitória/derrota).
