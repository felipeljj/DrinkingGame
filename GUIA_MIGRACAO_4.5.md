# Guia de Migração: Godot 4.4 → 4.5

## 📋 Checklist de Migração

### 1. Backup (IMPORTANTE!)
Antes de começar, faça backup do projeto:
- Faça commit de todas as alterações no Git
- Ou copie a pasta do projeto inteira para um local seguro

### 2. Instalar Godot 4.5
- Baixe o Godot 4.5 do site oficial
- Instale em uma pasta separada (não sobrescreva o 4.4 ainda)

### 3. Migração Automática do Projeto

#### Passo 1: Abrir o projeto no Godot 4.5
1. Abra o Godot 4.5
2. Clique em "Importar" ou "Abrir"
3. Navegue até a pasta do projeto e selecione `project.godot`
4. O Godot vai detectar que é um projeto 4.4 e perguntar se quer migrar
5. **Clique em "Migrar"** (não em "Abrir como 4.4")

#### Passo 2: O que acontece automaticamente
- ✅ O `project.godot` será atualizado para `config_version=5` (já está)
- ✅ A versão do engine será atualizada de "4.4" para "4.5"
- ✅ Os arquivos `.tscn` serão convertidos automaticamente
- ✅ Os scripts `.gd` serão verificados (geralmente compatíveis)

### 4. Verificar Configurações de Export

#### Android Export Presets
1. Vá em **Project → Export**
2. Verifique se os presets Android ainda estão configurados:
   - **Android (Release)**
   - **Android (Debug)**
   - Verifique se o keystore ainda está apontado corretamente

3. Se os presets sumiram, reconfigure:
   - Adicione novo preset Android
   - Configure o keystore: `android/keystore/drinkinggame-release.keystore`
   - Configure package name, version, etc.

#### Web Export Presets
- Verifique se os presets Web ainda estão funcionando
- Teste exportar para Web para garantir

### 5. Verificar Configurações do Projeto

#### Verificar `project.godot`
O arquivo será atualizado automaticamente, mas verifique:
```ini
config/features=PackedStringArray("4.5", "Mobile")  # Deve mudar de 4.4 para 4.5
```

#### Verificar Autoloads
Confirme que os autoloads ainda estão configurados:
- UIManager
- ParticlesManager
- LocalizationManager
- AchievementsManager

### 6. Testar o Projeto

#### Testes Básicos
1. **Execute o projeto** (F5) e teste:
   - Menu principal funciona?
   - Navegação entre cenas funciona?
   - Traduções funcionam?
   - Botões respondem?

2. **Teste funcionalidades específicas**:
   - Geração de cartas
   - Dado e roleta
   - Criador de packs
   - Conquistas
   - Histórico
   - Fotos

### 7. Possíveis Problemas e Soluções

#### Problema: Scripts com erros
**Solução**: Verifique o console de erros. Godot 4.5 pode ter pequenas mudanças na API.

#### Problema: Export presets perdidos
**Solução**: Reconfigure os presets de export. As configurações estão no `export_presets.cfg`.

#### Problema: Assets não carregam
**Solução**: 
- Vá em **Project → Reload Current Project**
- Ou feche e reabra o projeto

#### Problema: Erros de compilação Android
**Solução**: 
- Execute `android\limpar_build.bat`
- Tente exportar novamente

### 8. Atualizar Configurações do Android (se necessário)

Se houver problemas com o build Android:

1. Verifique se o `android/build/build.gradle` ainda está correto
2. Verifique se o `AndroidManifest.xml` está correto
3. Execute limpeza:
   ```bash
   cd android\build
   .\gradlew clean
   ```

### 9. Verificar Breaking Changes do 4.5

Consulte o changelog do Godot 4.5 para ver se há breaking changes que afetam seu projeto:
- [Godot 4.5 Release Notes](https://godotengine.org/article/dev-snapshot-godot-4-5-dev-1/)

### 10. Commit das Mudanças

Após migrar com sucesso:
```bash
git add .
git commit -m "Migração para Godot 4.5"
```

## ⚠️ Importante

- **NÃO** abra o projeto no 4.4 depois de migrar para 4.5 (pode corromper)
- **SEMPRE** faça backup antes de migrar
- **TESTE** tudo antes de fazer commit

## 📝 Arquivos que Serão Modificados

- `project.godot` - Atualizado automaticamente
- `*.tscn` - Convertidos automaticamente
- `export_presets.cfg` - Pode precisar de ajustes manuais
- Arquivos `.import` - Regenerados automaticamente

## ✅ Checklist Final

- [ ] Backup feito
- [ ] Projeto aberto no Godot 4.5
- [ ] Migração automática concluída
- [ ] Export presets verificados
- [ ] Projeto executado e testado
- [ ] Funcionalidades principais testadas
- [ ] Export Android testado
- [ ] Export Web testado (se aplicável)
- [ ] Commit feito

## 🆘 Se Algo Der Errado

1. **Restaure do backup**
2. **Abra no Godot 4.4** para continuar trabalhando
3. **Consulte a documentação** do Godot 4.5
4. **Verifique os logs** do Godot (Editor → Editor Settings → Network → Debug)



