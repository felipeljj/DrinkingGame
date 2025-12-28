# 📥 Como Instalar o JDK para Criar Keystore

## Opção 1: Adoptium (OpenJDK) - RECOMENDADO ✅

1. Acesse: https://adoptium.net/
2. Clique em **Latest LTS Release** (Java 17 ou 21)
3. Selecione:
   - **Operating System**: Windows
   - **Architecture**: x64
   - **Package Type**: JDK
4. Clique em **Download**
5. Execute o instalador e siga as instruções
6. **IMPORTANTE**: Marque a opção **"Add to PATH"** durante a instalação
7. Reinicie o terminal/PowerShell após instalar
8. Execute novamente: `.\criar_keystore.bat`

## Opção 2: Oracle JDK

1. Acesse: https://www.oracle.com/java/technologies/downloads/
2. Baixe o JDK para Windows x64
3. Instale normalmente
4. Adicione manualmente ao PATH:
   - Abra **Configurações do Sistema** → **Variáveis de Ambiente**
   - Adicione ao PATH: `C:\Program Files\Java\jdk-XX\bin` (substitua XX pela versão)
5. Reinicie o terminal
6. Execute: `.\criar_keystore.bat`

## Verificar se funcionou

Após instalar, execute:

```bash
java -version
keytool -help
```

Se ambos funcionarem, você está pronto!


