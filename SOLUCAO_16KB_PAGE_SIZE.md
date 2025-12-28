# Solução: Erro de Compatibilidade com Páginas de Memória de 16 KB

## Problema
Ao criar o arquivo `.aab` para upload na Google Play Store, você recebe o erro:
```
Seu app não é compatível com tamanhos de página de 16 KB de memória.
```

## Solução Aplicada

### build.gradle
O Android Gradle Plugin 8.2+ gerencia automaticamente o `extractNativeLibs` quando `useLegacyPackaging=false`. A configuração padrão já garante compatibilidade com páginas de 16 KB.

**IMPORTANTE**: Não adicione `android:extractNativeLibs` no AndroidManifest.xml - o AGP gerencia isso automaticamente e gerará avisos se você especificar manualmente.

## Por que isso funciona?

- **AGP 8.2+**: O Android Gradle Plugin versão 8.2+ gerencia automaticamente a extração de bibliotecas nativas para compatibilidade com páginas de 16 KB quando `useLegacyPackaging=false` (que é o padrão para minSdk >= 23).

- **Sem configuração manual necessária**: O AGP detecta automaticamente e configura o comportamento correto para suportar dispositivos com páginas de 16 KB.

### Nota Importante
- ❌ **NÃO** adicione `android:extractNativeLibs` no AndroidManifest.xml (gera aviso)
- ❌ **NÃO** use `android.bundle.enableUncompressedNativeLibs` (foi removido no AGP 8.1+)
- ✅ O AGP 8.2+ gerencia tudo automaticamente

## Próximos Passos

### Se encontrar erro "arquivo já está sendo usado":

1. **Feche o Godot completamente**

2. **Execute o script de limpeza** (Windows):
   ```bash
   android\limpar_build.bat
   ```
   Ou manualmente:
   ```bash
   cd android\build
   taskkill /F /IM java.exe
   taskkill /F /IM gradle.exe
   rmdir /s /q build
   rmdir /s /q .gradle
   gradlew clean --no-daemon
   ```

3. **Aguarde alguns segundos** para garantir que todos os processos foram finalizados

4. **Reabra o Godot e tente exportar novamente**

### Compilação normal:

1. No Godot: Export → Android → AAB (Release)

2. Teste o AAB gerado antes de fazer upload na Play Store

## Nota Importante

Se o erro persistir, pode ser necessário:
- Atualizar o NDK para uma versão mais recente (já está usando 23.2.8568313)
- Recompilar as bibliotecas nativas do Godot com suporte explícito a 16 KB
- Verificar se todas as dependências nativas são compatíveis

## Referências
- [Android 16 KB Page Size Support](https://developer.android.com/guide/practices/page-sizes)
- [Google Play Store Requirements](https://support.google.com/googleplay/android-developer/answer/11926878)

