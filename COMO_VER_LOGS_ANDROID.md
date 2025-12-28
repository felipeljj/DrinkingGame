# 📱 Como Ver Logs do Android

Este guia explica como visualizar os logs do seu jogo Godot no Android para debugar crashes e problemas.

## 🔧 Método 1: ADB (Android Debug Bridge) - Recomendado

### Pré-requisitos
1. Instalar Android SDK Platform Tools
   - Baixe em: https://developer.android.com/studio/releases/platform-tools
   - Ou instale via Android Studio: Tools → SDK Manager → SDK Tools → Android SDK Platform-Tools

2. Habilitar Depuração USB no dispositivo
   - Vá em Configurações → Sobre o telefone
   - Toque 7 vezes em "Número da versão" para ativar Modo Desenvolvedor
   - Volte e vá em Configurações → Opções do desenvolvedor
   - Ative "Depuração USB"

### Comandos ADB

#### Ver todos os logs em tempo real:
```bash
adb logcat
```

#### Filtrar apenas logs do Godot:
```bash
adb logcat | grep -i godot
```

#### Filtrar apenas erros e warnings:
```bash
adb logcat *:E *:W
```

#### Ver logs apenas do seu app:
```bash
adb logcat | grep -i "DrinkingGame"
```

#### Salvar logs em arquivo:
```bash
adb logcat > logs_android.txt
```

#### Limpar logs anteriores e começar do zero:
```bash
adb logcat -c && adb logcat
```

#### Ver logs de crash específicos:
```bash
adb logcat | grep -i "FATAL\|AndroidRuntime\|crash"
```

## 🎮 Método 2: Via Godot Editor

### Habilitar Remote Debug

1. No Godot Editor, vá em **Editor → Editor Settings**
2. Procure por **Network → Debug → Remote Port**
3. Configure a porta (padrão: 6006)

4. No Android, ao exportar, certifique-se de que:
   - **Debug → Remote Debug** está habilitado
   - O dispositivo está na mesma rede Wi-Fi que o PC

5. Conecte o dispositivo e inicie o app
6. No Godot Editor, vá em **Debugger → Remote**
7. Os logs aparecerão no painel **Output** do editor

## 📊 Método 3: Android Studio Logcat

1. Abra Android Studio
2. Conecte seu dispositivo via USB
3. Vá em **View → Tool Windows → Logcat**
4. Filtre por:
   - Package: `com.yourcompany.drinkinggame` (ou o nome do seu pacote)
   - Log Level: Error/Warning

## 🔍 Método 4: App de Terceiros

### Apps úteis:
- **Logcat Reader** (Google Play)
- **aLogcat** (Google Play)
- **CatLog** (Google Play)

Esses apps mostram os logs diretamente no dispositivo.

## 🐛 O que Procurar nos Logs

### Erros comuns relacionados a crashes:

1. **Null Pointer Exception:**
   ```
   FATAL EXCEPTION: main
   java.lang.NullPointerException
   ```

2. **Tween em nó destruído:**
   ```
   ERROR: Node not found in scene tree
   ```

3. **Vibração sem permissão:**
   ```
   ERROR: Vibration not available
   ```

4. **Problemas de memória:**
   ```
   FATAL: OutOfMemoryError
   ```

5. **Erros do Godot:**
   ```
   ERROR: (nome_do_script.gd:linha) - mensagem
   ```

## 💡 Dicas de Debug

### Adicionar logs customizados no código:

```gdscript
# Logs simples
print("Debug: Variável = ", valor)

# Logs de erro
push_error("Erro ao criar tween!")

# Logs de warning
push_warning("Nó pode estar destruído")

# Logs condicionais (só em debug)
if OS.is_debug_build():
    print("Debug info: ", informacao)
```

### Filtrar logs do seu código:

```bash
# Ver apenas seus prints
adb logcat | grep "Debug:"

# Ver apenas erros do Godot
adb logcat | grep "ERROR:"
```

## 🚀 Comando Rápido Recomendado

Para desenvolvimento, use este comando que mostra tudo relevante:

```bash
adb logcat -c && adb logcat | grep -E "godot|DrinkingGame|ERROR|FATAL|AndroidRuntime"
```

Este comando:
- Limpa logs antigos (`-c`)
- Mostra apenas linhas relevantes
- Filtra por Godot, nome do app, erros e crashes

## 📝 Exemplo de Uso

1. Conecte o dispositivo via USB
2. Abra o terminal/PowerShell
3. Execute: `adb logcat -c && adb logcat | grep -E "godot|DrinkingGame|ERROR|FATAL"`
4. Abra o app no dispositivo
5. Reproduza o crash
6. Os logs aparecerão no terminal mostrando o que causou o problema

## ⚠️ Troubleshooting

### ADB não reconhece o dispositivo:
- Instale os drivers USB do fabricante
- Tente outro cabo USB
- Verifique se a depuração USB está ativada

### Logs não aparecem:
- Verifique se o app está rodando
- Tente `adb devices` para ver se o dispositivo está conectado
- Reinicie o ADB: `adb kill-server && adb start-server`

### Muitos logs:
- Use filtros mais específicos
- Salve em arquivo e analise depois: `adb logcat > logs.txt`


