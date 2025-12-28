# 🔍 Como Procurar a Keystore Original no PC

## ❌ Problema

A Play Console rejeitou seu AAB porque ele foi assinado com uma keystore diferente da original.

**SHA1 Esperado:** `B6:FE:39:7E:AB:E9:25:91:CA:16:9F:F7:B0:87:D1:EF:52:FB:E0:30`

---

## ✅ Execute o Script de Busca

Execute este comando no PowerShell:

```powershell
cd "C:\Users\Latchuk\Documents\GitHub\DrinkingGame"
powershell -ExecutionPolicy Bypass -File procurar_keystore_original.ps1
```

O script procura automaticamente em todos os locais comuns.

---

## 📍 Onde Procurar Manualmente

Se o script não encontrar, procure manualmente nestes locais:

### 1. **Pasta do Projeto Atual e Antigos**
- `C:\Users\Latchuk\Documents\GitHub\`
- Procure em **outros projetos** (não só DrinkingGame)
- Procure na pasta `android\` ou `keystore\` de outros projetos

### 2. **Desktop e Documentos**
- `C:\Users\Latchuk\Desktop\`
- `C:\Users\Latchuk\Documents\`
- Procure por arquivos `.keystore` ou `.jks`

### 3. **OneDrive / Google Drive / Dropbox**
- Verifique suas pastas de sincronização na nuvem
- Pode estar em backup automático

### 4. **Downloads**
- `C:\Users\Latchuk\Downloads\`
- Pode ter baixado ou recebido a keystore por email

### 5. **Android Studio**
- `C:\Users\Latchuk\AndroidStudioProjects\`
- Procure em projetos antigos do Android Studio
- Verifique configurações do Android Studio

### 6. **Pastas .android**
- `C:\Users\Latchuk\.android\`
- Embora geralmente seja debug.keystore, pode ter guardado lá

### 7. **Backups**
- HD externo
- Pendrive
- Serviços de backup (Time Machine, etc.)

### 8. **Emails**
- Procure emails antigos sobre o app
- Pode ter enviado ou recebido a keystore por email
- Verifique anexos antigos

---

## 🔍 Verificar Manualmente se uma Keystore é a Correta

Para verificar o SHA1 de uma keystore que você encontrou:

```powershell
$keytoolPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
& $keytoolPath -list -v -keystore "CAMINHO_PARA_KEYSTORE"
```

Digite a senha quando solicitado e procure por:

```
SHA1: B6:FE:39:7E:AB:E9:25:91:CA:16:9F:F7:B0:87:D1:EF:52:FB:E0:30
```

Se aparecer exatamente esse SHA1, **essa é a keystore correta!**

---

## 📝 Checklist de Busca

- [ ] Desktop
- [ ] Documentos (todas as subpastas)
- [ ] Downloads
- [ ] OneDrive / Google Drive / Dropbox
- [ ] Projetos GitHub antigos
- [ ] AndroidStudioProjects
- [ ] Pastas .android
- [ ] HD externo / Pendrive
- [ ] Emails antigos
- [ ] Backup na nuvem
- [ ] Outros desenvolvedores (se trabalha em equipe)

---

## ⚠️ Se Não Encontrar

### Opção 1: Verificar com Outros Desenvolvedores
Se você trabalha em equipe, pergunte se alguém tem a keystore original.

### Opção 2: Assinatura pelo Google Play
Na Play Console:
1. Vá em **Configuração do app → Assinatura do app**
2. Se disponível, ative **"Assinatura pelo Google Play"**
3. Isso só funciona se o app não estiver em produção ainda

### Opção 3: Criar Novo App (ÚLTIMA OPÇÃO)
Se você **não conseguir encontrar** a keystore original:
- Crie um **novo app** na Play Console
- Com um **novo package name**
- ⚠️ Isso significa perder reviews e histórico do app antigo!

---

## 💡 Dicas

1. **Procure por nome do app**: A keystore pode ter nome relacionado ao app
2. **Procure por data**: Veja quando o app foi criado na Play Console e procure arquivos dessa época
3. **Verifique documentação**: Pode ter anotado a localização da keystore
4. **Verifique repositórios**: Se usa Git, pode ter commitado a keystore (não recomendado, mas pode estar lá)

---

Execute o script `procurar_keystore_original.ps1` primeiro, depois procure manualmente nos locais listados!



