# Como Fazer Deploy do Jogo para Web (iOS/Browser)

## 1. Exportar o Jogo

1. Abra o projeto no Godot
2. Vá em **Project > Export**
3. Selecione o preset **"Web"**
4. Clique em **"Export Project"**
5. Escolha onde salvar (ex: `web/DrinkingGame.html`)

## 2. Configurações Otimizadas para iOS

O preset Web já está configurado com:
- ✅ PWA (Progressive Web App) habilitado
- ✅ Meta tags para iOS Safari
- ✅ Suporte a teclado virtual
- ✅ Orientação portrait fixa
- ✅ Ícones configurados

## 3. Hospedar os Arquivos

Você precisa hospedar os seguintes arquivos gerados:
- `DrinkingGame.html`
- `DrinkingGame.js`
- `DrinkingGame.wasm`
- `DrinkingGame.pck`
- `DrinkingGame.audio.worklet.js`
- `DrinkingGame.audio.position.worklet.js`
- `DrinkingGame.service.worker.js`
- `DrinkingGame.offline.html`
- `DrinkingGame.manifest.json`
- `icon.png` (se configurado)

### Opções de Hospedagem:

#### Opção 1: GitHub Pages (Grátis)
1. Crie um repositório no GitHub
2. Faça upload dos arquivos exportados
3. Ative GitHub Pages nas configurações do repositório
4. Acesse via: `https://seu-usuario.github.io/repositorio/DrinkingGame.html`

#### Opção 2: Netlify (Grátis)
1. Acesse [netlify.com](https://netlify.com)
2. Conecte seu repositório GitHub
3. Configure:
   - **Build command**: (deixe vazio)
   - **Publish directory**: `.` (ponto, raiz do repositório)
   - Ou se os arquivos estão em uma pasta: `Drink's Browser` (nome da pasta)
4. Adicione os arquivos `netlify.toml` e `_redirects` na raiz do repositório
5. Faça commit e push
6. O Netlify vai fazer deploy automaticamente!

**IMPORTANTE**: Certifique-se de que:
- Todos os arquivos exportados estão no repositório
- O arquivo `netlify.toml` está na raiz
- O arquivo `_redirects` está na raiz (se usar)

#### Opção 3: Vercel (Grátis)
1. Acesse [vercel.com](https://vercel.com)
2. Conecte seu repositório GitHub
3. Configure o build (não precisa, só upload dos arquivos)

## 4. Adicionar ao iOS Home Screen

### Para Usuários:
1. Abra o jogo no Safari do iOS
2. Toque no botão de compartilhar (quadrado com seta)
3. Selecione **"Adicionar à Tela de Início"**
4. O jogo aparecerá como um app nativo!

## 5. Configurações Importantes

### HTTPS Obrigatório
- PWA e Service Workers só funcionam em HTTPS
- Use um serviço de hospedagem que forneça HTTPS (GitHub Pages, Netlify, Vercel todos fornecem)

### Service Worker
- O jogo já está configurado com Service Worker para funcionar offline
- Funciona automaticamente após o primeiro acesso

## 6. Testar no iOS

1. Abra o Safari no iPhone/iPad
2. Acesse a URL do jogo
3. Teste todas as funcionalidades:
   - ✅ Navegação entre telas
   - ✅ Geração de cartas
   - ✅ Filtros
   - ✅ Conquistas
   - ✅ Configurações
   - ⚠️ Câmera (pode precisar de permissão)
   - ⚠️ Vibração (funciona no iOS 13+)

## 7. Limitações no Browser

- **Vibração**: Funciona no iOS 13+ via Vibration API
- **Câmera**: Precisa de permissão do usuário (primeira vez)
- **Armazenamento**: Usa localStorage (limitado a ~5-10MB)
- **Performance**: Pode ser mais lenta que app nativo

## 8. Otimizações Aplicadas

- ✅ Compressão de texturas para mobile
- ✅ Thread support habilitado
- ✅ Extensions support habilitado
- ✅ Canvas resize policy otimizado
- ✅ Viewport configurado para iOS
- ✅ Meta tags para PWA no iOS

## 9. Troubleshooting

### Jogo não carrega
- Verifique se todos os arquivos estão na mesma pasta
- Verifique se está usando HTTPS
- Abra o console do navegador (F12) para ver erros

### PWA não funciona
- Certifique-se de estar usando HTTPS
- Verifique se o manifest.json está acessível
- Limpe o cache do navegador

### Performance ruim
- Reduza qualidade de texturas no export
- Desabilite algumas partículas
- Teste em diferentes dispositivos

