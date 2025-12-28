# Solução: Page Not Found no Netlify

## Problema
O Netlify está retornando "Page Not Found" porque não sabe qual arquivo servir.

## Soluções

### Opção 1: Arquivos na Raiz (Recomendado)

1. **Mova os arquivos exportados para a raiz do repositório:**
   - Se você exportou para `Drink's Browser/`, mova todos os arquivos para a raiz
   - Arquivos necessários:
     - `DrinkingGame.html`
     - `DrinkingGame.js`
     - `DrinkingGame.wasm`
     - `DrinkingGame.pck`
     - `DrinkingGame.service.worker.js`
     - `DrinkingGame.offline.html`
     - `DrinkingGame.manifest.json`
     - `DrinkingGame.audio.worklet.js`
     - `DrinkingGame.audio.position.worklet.js`

2. **Atualize o `netlify.toml`:**
   ```toml
   [build]
     publish = "."

   [[redirects]]
     from = "/"
     to = "/DrinkingGame.html"
     status = 200
   ```

3. **Atualize o `_redirects`:**
   ```
   /*    /DrinkingGame.html   200
   ```

### Opção 2: Arquivos na Pasta "Drink's Browser"

1. **Mantenha os arquivos na pasta `Drink's Browser/`**

2. **Configure o Netlify:**
   - No painel do Netlify, vá em **Site settings > Build & deploy**
   - Em **Publish directory**, coloque: `Drink's Browser`
   - Salve

3. **Atualize o `netlify.toml`:**
   ```toml
   [build]
     publish = "Drink's Browser"

   [[redirects]]
     from = "/"
     to = "/DrinkingGame.html"
     status = 200
   ```

### Opção 3: Usar index.html (Mais Simples)

1. **Renomeie o arquivo:**
   - Renomeie `DrinkingGame.html` para `index.html`

2. **O Netlify automaticamente servirá o `index.html` na raiz**

3. **Não precisa de redirects!**

## Verificar se Funcionou

1. Faça commit e push dos arquivos de configuração
2. O Netlify vai fazer redeploy automaticamente
3. Acesse a URL do seu site
4. Deve carregar o jogo!

## Troubleshooting

### Ainda dando 404?
- Verifique se todos os arquivos estão no repositório
- Verifique se o `netlify.toml` está na raiz
- Veja os logs do deploy no Netlify (Build log)
- Certifique-se de que o caminho no `netlify.toml` está correto

### Arquivos não encontrados?
- Verifique se os arquivos `.wasm`, `.js`, `.pck` estão no mesmo diretório do HTML
- Todos os arquivos devem estar acessíveis via HTTP

### Service Worker não funciona?
- Certifique-se de que está usando HTTPS (Netlify fornece automaticamente)
- Verifique se o `DrinkingGame.service.worker.js` está acessível





