# 🔑 Como Criar a Keystore - Resolvendo Problema de Input

Se o script `.bat` não permite digitar, use uma destas soluções:

## ✅ Solução 1: Usar o Script PowerShell (RECOMENDADO)

Execute no PowerShell:

```powershell
.\criar_keystore.ps1
```

Se der erro de política de execução, execute antes:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Depois execute o script novamente.

---

## ✅ Solução 2: Executar Diretamente no CMD (mais simples)

Abra o **CMD** (Prompt de Comando) ou **PowerShell** e execute:

```cmd
"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore android\keystore\drinkinggame-release.keystore -alias drinkinggame -keyalg RSA -keysize 2048 -validity 10000
```

**IMPORTANTE:** 
- Certifique-se de estar na pasta do projeto: `cd C:\Users\Latchuk\Documents\GitHub\DrinkingGame`
- Crie a pasta primeiro: `mkdir android\keystore` (se não existir)
- Use uma senha com **NO MÍNIMO 6 caracteres**

---

## ✅ Solução 3: Usar o Android Studio

1. Abra o **Android Studio**
2. Vá em **Build → Generate Signed Bundle / APK**
3. Selecione **Android App Bundle**
4. Se você já tem uma keystore, escolha-a
5. Se não tem, clique em **Create new...**
6. Preencha os dados
7. Guarde o arquivo `.jks` gerado em `android\keystore\`
8. Use no Godot (pode usar arquivos `.jks` também)

---

## 📋 O que você precisará preencher:

Quando executar o keytool, você será perguntado:

1. **Senha da keystore** ⚠️ (mínimo 6 caracteres - use uma senha forte!)
2. **Confirmação da senha** (digite novamente)
3. **Nome completo** (seu nome ou nome da empresa)
4. **Unidade organizacional** (pode deixar vazio - apenas Enter)
5. **Organização** (ex: "Drink's Deck")
6. **Cidade** (sua cidade)
7. **Estado** (seu estado)
8. **Código do país** (BR para Brasil)
9. **Confirmar** (digite `yes`)
10. **Senha do alias** (geralmente a mesma da keystore)

---

## ⚠️ Problemas Comuns

### "Não consigo digitar no script"
- Use o **PowerShell** diretamente (Solução 1 ou 2)
- Ou abra o CMD como Administrador

### "Senha muito curta"
- Use uma senha com **pelo menos 6 caracteres**
- Recomendado: **8+ caracteres** com letras, números e símbolos

### "Excesso de falhas"
- Feche e abra o terminal novamente
- Execute o comando diretamente (Solução 2)

---

Depois de criar a keystore, configure no Godot Editor conforme o guia `COMO_ASSINAR_ANDROID.md`!


