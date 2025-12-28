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
		$ScrollContainer/VBoxContainer/Title.text = LocalizationManager.translate("credits_title", "CRÉDITOS")
	if has_node("ScrollContainer/VBoxContainer/DeveloperSection"):
		$ScrollContainer/VBoxContainer/DeveloperSection.text = LocalizationManager.translate("credits_developed_by", "Desenvolvido com muito amor por")
	if has_node("ScrollContainer/VBoxContainer/DeveloperName"):
		$ScrollContainer/VBoxContainer/DeveloperName.text = "Felipe Latchuk"
	if has_node("ScrollContainer/VBoxContainer/TestersSection"):
		$ScrollContainer/VBoxContainer/TestersSection.text = LocalizationManager.translate("credits_thanks_testers", "Agradecimento aos Testers")
	if has_node("ScrollContainer/VBoxContainer/TestersList"):
		$ScrollContainer/VBoxContainer/TestersList.text = LocalizationManager.translate("credits_testers_list", "Ana Livia\nBela henning\nCecilia Oliveira\nEric Simões\nFrancisco Rios de Almeida\nGabriela Salmon\nGiulia Souza\nGuilherme Kaue\nGustavo Arcoverde\nLeonardo Bertoli\nLucas Beraldin\nLuiz Filipe Egri Filho\nNate Armstrong\nNicole Pastuch\nPatrick Pereira\nSilvia Riechi\nSofia Kawazoe")
	if has_node("VoltarButton"):
		$VoltarButton.text = LocalizationManager.translate("credits_back_button", "Voltar")

func _on_voltar_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/menu.tscn")





