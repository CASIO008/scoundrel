# Localização (Inglês, Português, Chinês Simplificado)

Adicionar suporte a 3 idiomas à interface do jogo exige modificações substanciais em todo o código, para remover textos codificados diretamente e substituí-los por um dicionário dinâmico.

## User Review Required

> [!IMPORTANT]  
> A fonte original do jogo (`Fifties Movies.ttf`, `Gothik Steel.ttf`, etc) **NÃO possui suporte a caracteres do idioma Chinês**.
> Para renderizar Chinês Simplificado no LÖVE2D de forma segura, a abordagem proposta usará a fonte padrão do sistema operacional do usuário (`C:\Windows\Fonts\msyh.ttc` - Microsoft YaHei) sempre que o idioma selecionado for Chinês. Se a fonte não existir, os caracteres em chinês aparecerão como pequenos quadrados de erro. 
> Confirme se concorda com a utilização da fonte Microsoft YaHei para textos em chinês.

## Proposed Changes

### main.lua

#### [MODIFY] main.lua
- Criar a tabela `i18n` com todos os textos da UI em `en`, `pt` e `zh`.
- Criar a variável `currentLang = "pt"` (já que pediu em pt antes, ou "en" como default) e injetá-la no salvamento/carregamento (dentro de `privy_save.lua`).
- Inserir uma **nova opção** no menu ("IDIOMA / LANGUAGE / 语言") como a Opção 6, movendo a opção "LEAVE A LEGACY / BACK TO MENU" para a Opção 7. Ajustar a lógica de limite do `menuSelection` e do enter (ação 7 agora sai do jogo/volta ao menu).
- Adicionar no `love.keypressed` ("right" e "left") o controle sobre a opção 6 para ciclar entre `en`, `pt` e `zh`.
- Ao alterar o idioma, disparar a reconstrução das fontes. As fontes customizadas (`Fifties Movies.ttf`, etc) só serão carregadas se o idioma for `en` ou `pt`. Se for `zh`, carregaremos `msyh.ttc` com os mesmos tamanhos, pois ela tem os caracteres (Glifos) necessários.
- Buscar pelo código todos os `love.graphics.printf`, `textShadowed`, `drawBulgingText` e textos de botões (`btnTrash`, `btnRun`) e envolvê-los na consulta ao dicionário (ex: `i18n[currentLang].play`).

## Verification Plan

### Automated Tests
- N/A

### Manual Verification
- Clicar nas configurações e ir até a nova opção de Idioma. Alternar entre EN, PT e ZH.
- Verificar se todas as strings da tela, o menu de combate radial (FISTS, WEAPON) e a tela de GAME OVER estão sendo perfeitamente traduzidos.
- Verificar se a mudança pro chinês altera a fonte para Microsoft YaHei sem gerar crash ou caracteres quadrados.
