# 📱 Como Assinar o Pacote Android (AAB/APK)

Este guia explica como assinar o pacote Android para fazer upload na Play Console.

## ⚠️ IMPORTANTE: Guarde a Keystore com Segurança!

**A keystore é CRÍTICA!** Se você perder ou esquecer a senha:
- ❌ **NUNCA** poderá atualizar seu app na Play Store
- ❌ Precisará criar um novo app com novo package name
- ✅ Guarde em local seguro (pasta criptografada, pendrive, backup na nuvem)

---

## 📋 Passo 1: Criar a Keystore (Java KeyStore)

### No Windows (PowerShell ou CMD):

```powershell
keytool -genkey -v -keystore drinkinggame-release.keystore -alias drinkinggame -keyalg RSA -keysize 2048 -validity 10000
```

### No Linux/Mac:

```bash
keytool -genkey -v -keystore drinkinggame-release.keystore -alias drinkinggame -keyalg RSA -keysize 2048 -validity 10000
```

### O que você será perguntado:

1. **Senha da keystore** (guarde bem!): Digite uma senha forte
2. **Confirmação da senha**: Digite novamente
3. **Nome completo**: Seu nome ou nome da empresa
4. **Unidade organizacional**: (pode deixar em branco pressionando Enter)
5. **Organização**: Nome da sua empresa/app (ex: "Drink's Deck")
6. **Cidade ou Localidade**: Sua cidade
7. **Estado ou Província**: Seu estado
8. **Código do país**: BR (Brasil) ou outro código de 2 letras
9. **Confirmar informações**: Digite `yes`
10. **Senha da chave** (alias): Digite a mesma senha da keystore ou outra (recomendo a mesma)

### Resultado:
- Será criado o arquivo `drinkinggame-release.keystore` no diretório onde você executou o comando
- **MOVA ESTE ARQUIVO PARA UM LOCAL SEGURO!** (Ex: pasta `android/keystore/` ou `android/` na raiz do projeto)

---

## 📋 Passo 2: Configurar no Godot Editor

### Opção A: Pela Interface do Godot (Recomendado)

1. Abra o Godot Editor
2. Vá em **Project → Export**
3. Selecione o preset **Android**
4. Clique em **Options** (ou expanda as opções se não estiverem visíveis)
5. Procure por **Package → Keystore/Release**
6. Configure:
   - **Use Keystore**: ✅ Marque esta opção
   - **Keystore File**: Clique em **"..."** e selecione o arquivo `drinkinggame-release.keystore`
   - **Keystore Password**: Digite a senha da keystore
   - **Keystore User Alias**: Digite `drinkinggame` (o alias que você criou)
   - **Keystore User Password**: Digite a senha da chave (geralmente a mesma da keystore)

7. Clique em **Save** ou **Apply**

### Opção B: Editar Manualmente o export_presets.cfg

Se preferir editar manualmente, adicione estas linhas na seção `[preset.0.options]`:

```ini
# ... outras configurações ...

# Configurações de Assinatura (Release)
keystore/release="C:/Users/Latchuk/Documents/GitHub/DrinkingGame/android/drinkinggame-release.keystore"
keystore/release_user="drinkinggame"
keystore/release_password="SUA_SENHA_AQUI"
```

**⚠️ ATENÇÃO**: O arquivo `export_presets.cfg` não deve ser commitado no Git se contiver senhas! Adicione ao `.gitignore`:

---

## 📋 Passo 3: Adicionar ao .gitignore

Adicione estas linhas ao arquivo `.gitignore`:

```
# Android Keystores (NUNCA commitar!)
*.keystore
*.jks
android/*.keystore
android/keystore/

# export_presets.cfg pode conter senhas - considere não commitar ou usar variáveis de ambiente
# export_presets.cfg
```

---

## 📋 Passo 4: Exportar o AAB Assinado

1. No Godot Editor, vá em **Project → Export**
2. Selecione o preset **Android**
3. Clique em **Export Project**
4. Escolha onde salvar o arquivo (ex: `PLAYSTORE/DrinkingGame.aab`)
5. O Godot irá assinar automaticamente o AAB durante o export

---

## ✅ Verificar Assinatura do AAB

Para verificar se o AAB está assinado corretamente:

```bash
jarsigner -verify -verbose -certs PLAYSTORE/DrinkingGame.aab
```

Ou usando o `bundletool` (mais recomendado):

```bash
bundletool verify --bundle=PLAYSTORE/DrinkingGame.aab
```

---

## 🔧 Resolução de Problemas

### Erro: "Keystore file was not found"
- Verifique se o caminho da keystore está correto
- Use caminho absoluto (ex: `C:/caminho/completo/para/keystore.keystore`)
- No Windows, use barras `/` ou `\\` no caminho

### Erro: "Keystore was tampered with, or password was incorrect"
- Verifique se a senha está correta
- Certifique-se de usar a mesma senha que você criou
- Se esqueceu a senha, você precisará criar uma nova keystore

### Erro: "Alias does not exist"
- Verifique se o alias (nome da chave) está correto
- Use `keytool -list -v -keystore drinkinggame-release.keystore` para ver os aliases disponíveis

### Ver aliases disponíveis na keystore:

```bash
keytool -list -v -keystore drinkinggame-release.keystore
```

Digite a senha quando solicitado e você verá todos os aliases (chaves) na keystore.

---

## 📦 Play Console - Upload

1. Acesse https://play.google.com/console
2. Selecione seu app
3. Vá em **Production** (ou **Internal testing** / **Closed testing**)
4. Clique em **Create new release**
5. Faça upload do arquivo `.aab` assinado
6. A Play Console verificará a assinatura automaticamente
7. Se aparecer "Todos os pacotes enviados precisam ser assinados", significa que o AAB não está assinado corretamente - volte ao Passo 2

---

## 🔐 Segurança - Backup da Keystore

**Fazer backup é ESSENCIAL!**

### Onde guardar:
1. ✅ Pendrive ou HD externo (guardado em local seguro)
2. ✅ Serviço de backup na nuvem criptografado (Google Drive, Dropbox, etc.)
3. ✅ Imprimir informações importantes (não a senha!) em papel guardado em cofre
4. ❌ **NÃO** commitar no Git/GitHub público
5. ❌ **NÃO** enviar por email sem criptografar

### Informações para guardar:
- Localização do arquivo `.keystore`
- Alias (nome da chave)
- Senha da keystore
- Senha do alias (se diferente)
- Validade da keystore (10000 dias = ~27 anos)

---

## 📝 Notas Adicionais

- A keystore de **release** é diferente da keystore de **debug**
- Para publicar na Play Store, use sempre a keystore de **release**
- O AAB é a forma recomendada pela Google para upload na Play Store
- Você pode criar múltiplas chaves (aliases) na mesma keystore, mas recomendo usar apenas uma por app

---

## 🆘 Precisa de Ajuda?

Se encontrar problemas:
1. Verifique se o Java JDK está instalado (`java -version` e `keytool -help`)
2. Certifique-se de que o caminho da keystore está correto no Godot
3. Tente exportar novamente após configurar a keystore
4. Verifique os logs do Godot para mais detalhes do erro


