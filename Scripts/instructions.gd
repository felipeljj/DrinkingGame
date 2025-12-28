extends Control

func _ready():
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Adicionar hover effect
	if has_node("VoltarButton"):
		UIManager.add_button_hover_effect($VoltarButton)

func _update_ui_texts():
	if has_node("ScrollContainer/VBoxContainer/Title"):
		$ScrollContainer/VBoxContainer/Title.text = LocalizationManager.translate("instructions_title", "COMO JOGAR")
	if has_node("ScrollContainer/VBoxContainer/Section1"):
		$ScrollContainer/VBoxContainer/Section1.text = LocalizationManager.translate("instructions_section1_title", "📱 BÁSICO")
	if has_node("ScrollContainer/VBoxContainer/Text1"):
		$ScrollContainer/VBoxContainer/Text1.text = LocalizationManager.translate("instructions_section1_text", "1. Selecione os packs de cartas que deseja jogar\n2. Passe o celular de mão em mão na roda\n3. Cada pessoa desliza para ver uma nova carta\n4. Cumpra o desafio ou beba!")
	if has_node("ScrollContainer/VBoxContainer/Section2"):
		$ScrollContainer/VBoxContainer/Section2.text = LocalizationManager.translate("instructions_section2_title", "🎮 CONTROLES")
	if has_node("ScrollContainer/VBoxContainer/Text2"):
		$ScrollContainer/VBoxContainer/Text2.text = LocalizationManager.translate("instructions_section2_text", "• Deslize para os lados para trocar de carta\n• Toque no botão quando não puder deslizar\n• Use o botão 'Sair' para ver o WRAPPED e voltar ao menu")
	if has_node("ScrollContainer/VBoxContainer/Section3"):
		$ScrollContainer/VBoxContainer/Section3.text = LocalizationManager.translate("instructions_section3_title", "PACKS DISPONÍVEIS")
	if has_node("ScrollContainer/VBoxContainer/Text3"):
		$ScrollContainer/VBoxContainer/Text3.text = LocalizationManager.translate("instructions_section3_text", "• CLÁSSICO: Para todos os gostos\n• NON-SENSE: Desafios bizarros e engraçados\n• WEIRDO: Para quem gosta de agir como estranhão\n• IDIOMAS: Teste suas habilidades linguísticas\n• VOTAÇÃO: Quem é mais provável de...?\n• SPICY: Conteúdo adulto (+18)\n• Packs customizados")
	if has_node("ScrollContainer/VBoxContainer/Section4"):
		$ScrollContainer/VBoxContainer/Section4.text = LocalizationManager.translate("instructions_section4_title", "AVISO")
	if has_node("ScrollContainer/VBoxContainer/Text4"):
		$ScrollContainer/VBoxContainer/Text4.text = LocalizationManager.translate("instructions_section4_text", "Este jogo é feito exclusivamente para público adulto.\nNão beba se for menor de idade.\nBeba com responsabilidade e se divirta!")
	if has_node("VoltarButton"):
		$VoltarButton.text = LocalizationManager.translate("instructions_back_button", "Voltar")

func _on_voltar_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/menu.tscn")
