# 🔑 Encontrar Keystore Original da Play Console

## ❌ Problema

A Play Console está rejeitando seu AAB porque ele foi assinado com uma **keystore diferente** da original.

**SHA1 Esperado (keystore original):**
```
B6:FE:39:7E:AB:E9:25:91:CA:16:9F:F7:B0:87:D1:EF:52:FB:E0:30
```

**SHA1 Atual (keystore que você acabou de criar):**
```
11:8D:5F:1F:F8:6B:72:75:23:FF:72:98:F0:BC:51:E8:17:9E:5C:AF
```

---

## ✅ Soluções

### Opção 1: Encontrar a Keystore Original (RECOMENDADO)

A keystore original que foi usada no primeiro upload precisa ser encontrada. Procure por:

#### Locais comuns:
1. **Pasta do projeto antigo** (se foi exportado antes)
2. **Backups** (HD externo, nuvem, etc.)
3. **Android Studio** - Se foi criada lá:
   - `%USERPROFILE%\.android\debug.keystore` (não é essa - é para debug)
   - Pasta do projeto Android Studio antigo
4. **Unity/Godot projects anteriores**
5. **Desktop ou Documentos** - Arquivos `.keystore` ou `.jks`

#### Como verificar se uma keystore é a correta:

Execute este comando substituindo `CAMINHO_PARA_KEYSTORE`:

```powershell
$keytoolPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
& $keytoolPath -list -v -keystore "CAMINHO_PARA_KEYSTORE" | Select-String "SHA1:"
```

Se o SHA1 mostrar `B6:FE:39:7E:AB:E9:25:91:CA:16:9F:F7:B0:87:D1:EF:52:FB:E0:30`, essa é a keystore correta!

---

### Opção 2: Verificar no Android Studio (se foi criada lá)

1. Abra o **Android Studio**
2. Vá em **Build → Generate Signed Bundle / APK**
3. Se você criou a keystore lá antes, ela deve estar salva
4. Veja o caminho que aparece quando seleciona a keystore

---

### Opção 3: Verificar com outros desenvolvedores/equipe

Se você trabalha em equipe:
- Alguém mais pode ter a keystore original
- Pode estar em um repositório seguro compartilhado
- Pode ter sido criada por outra pessoa

---

### Opção 4: Usar a Assinatura do Google Play (APK/AAB signing by Google Play)

Se você **não conseguir encontrar** a keystore original:

1. Na **Play Console**, vá em **Configuração do app → Assinatura do app**
2. Você pode ativar a **"Assinatura do app pelo Google Play"**
3. Isso permite que a Google assine automaticamente seus pacotes
4. **ATENÇÃO**: Isso só funciona se você ainda não tiver publicado o app em produção

---

### ⚠️ Opção 5: Criar Novo App (ÚLTIMA OPÇÃO)

Se você **NÃO conseguir encontrar** a keystore original e o app **não estiver em produção ainda**:

- Você precisará criar um **novo app** na Play Console
- Com um **novo package name** (ex: `com.example.drinksdeck2`)
- Isso significa perder todas as reviews, downloads e histórico do app antigo
- **NÃO RECOMENDADO** se o app já está publicado!

---

## 🔍 Script para Procurar Keystore

Execute este script PowerShell para procurar todas as keystores:

```powershell
$keytoolPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
$targetSHA1 = "B6:FE:39:7E:AB:E9:25:91:CA:16:9F:F7:B0:87:D1:EF:52:FB:E0:30"

Write-Host "Procurando keystore com SHA1: $targetSHA1" -ForegroundColor Yellow

$locations = @(
    "$env:USERPROFILE",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\.android",
    "C:\"
)

foreach ($loc in $locations) {
    if (Test-Path $loc) {
        Get-ChildItem -Path $loc -Recurse -Include "*.keystore","*.jks" -ErrorAction SilentlyContinue -Depth 2 | ForEach-Object {
            try {
                $sha1 = & $keytoolPath -list -v -keystore $_.FullName 2>&1 | Select-String -Pattern "SHA1:\s*([0-9A-F:]+)" | ForEach-Object { ($_ -split "SHA1:")[1].Trim() }
                if ($sha1 -eq $targetSHA1) {
                    Write-Host "ENCONTRADA! $($_.FullName)" -ForegroundColor Green
                    Write-Host "SHA1: $sha1" -ForegroundColor Cyan
                    return
                }
            } catch {
                # Ignorar erros de keystores com senha incorreta
            }
        }
    }
}

Write-Host "Keystore nao encontrada nos locais comuns." -ForegroundColor Red
```

---

## 📝 Depois de Encontrar a Keystore Original

1. **Copie a keystore** para `android\keystore\` (ou outro local seguro)
2. **Configure no Godot**:
   - Project → Export → Android → Options
   - Keystore/Release → Use a keystore original
   - Digite a senha correta da keystore original
   - Use o alias correto da keystore original
3. **Exporte o AAB novamente**
4. **Faça upload na Play Console**

---

## ⚠️ IMPORTANTE

**Se você perder a keystore original:**
- ❌ Você **NUNCA** poderá atualizar o app existente
- ❌ Precisará criar um novo app com novo package name
- ❌ Perderá todas as reviews e histórico

**Por isso, é CRÍTICO encontrar a keystore original!**

---

## 💡 Dicas para Evitar Isso no Futuro

1. **Guarde a keystore em local seguro**: Backup na nuvem, pendrive, etc.
2. **Use um gerenciador de senhas**: Guarde a senha da keystore
3. **Documente**: Anote onde está a keystore e a senha
4. **Backup**: Faça backup da keystore em múltiplos lugares seguros


