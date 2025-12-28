extends Control

@onready var achievements_list = $ScrollContainer/VBoxContainer/AchievementsList
@onready var title_label = $ScrollContainer/VBoxContainer/Title

func _ready():
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Adicionar hover effect
	if has_node("VoltarButton"):
		UIManager.add_button_hover_effect($VoltarButton)
	
	# Carregar e exibir conquistas
	_load_achievements()

func _update_ui_texts():
	if title_label:
		title_label.text = LocalizationManager.translate("achievements_title", "CONQUISTAS")
	if has_node("VoltarButton"):
		$VoltarButton.text = LocalizationManager.translate("achievements_back_button", "Voltar")

func _load_achievements():
	if not AchievementsManager:
		return
	
	# Limpar lista existente
	for child in achievements_list.get_children():
		child.queue_free()
	
	# Obter todas as conquistas
	var all_achievements = AchievementsManager.get_all_achievements()
	
	for achievement in all_achievements:
		_create_achievement_card(achievement)

func _create_achievement_card(achievement: Dictionary):
	# HBox como container principal do card
	var card = HBoxContainer.new()
	card.add_theme_constant_override("separation", 15)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Estilo de fundo usando PanelContainer
	var panel_style = StyleBoxFlat.new()
	if achievement.get("unlocked", false):
		panel_style.bg_color = Color(0.2, 0.6, 0.2, 0.8)
		panel_style.border_color = Color(0.4, 0.8, 0.4, 1)
	else:
		panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
		panel_style.border_color = Color(0.3, 0.3, 0.3, 1)
	
	panel_style.set_corner_radius_all(15)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.content_margin_left = 20
	panel_style.content_margin_right = 20
	panel_style.content_margin_top = 15
	panel_style.content_margin_bottom = 15
	card.add_theme_stylebox_override("panel", panel_style)
	
	# Usar PanelContainer para ter o fundo
	var panel_container = PanelContainer.new()
	panel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_container.add_theme_stylebox_override("panel", panel_style)
	
	var inner_hbox = HBoxContainer.new()
	inner_hbox.add_theme_constant_override("separation", 15)
	panel_container.add_child(inner_hbox)
	
	# Ícone
	var icon_label = Label.new()
	icon_label.text = achievement.get("icon", "🏆")
	icon_label.add_theme_font_size_override("font_size", 50)
	icon_label.custom_minimum_size = Vector2(70, 70)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inner_hbox.add_child(icon_label)
	
	# VBox para textos
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	inner_hbox.add_child(vbox)
	
	# Nome
	var name_label = Label.new()
	name_label.text = achievement.get("name", "Conquista")
	name_label.add_theme_font_size_override("font_size", 36)
	if achievement.get("unlocked", false):
		name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	else:
		name_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
	vbox.add_child(name_label)
	
	# Descrição
	var desc_label = Label.new()
	desc_label.text = achievement.get("description", "")
	desc_label.add_theme_font_size_override("font_size", 24)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if achievement.get("unlocked", false):
		desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
	else:
		desc_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	vbox.add_child(desc_label)
	
	# Data de desbloqueio (se desbloqueada)
	if achievement.get("unlocked", false) and achievement.get("unlocked_date"):
		var date_label = Label.new()
		var unlocked_text = LocalizationManager.translate("achievement_unlocked_at", "Desbloqueada: %s")
		date_label.text = unlocked_text % achievement.get("unlocked_date", "")
		date_label.add_theme_font_size_override("font_size", 20)
		date_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		vbox.add_child(date_label)
	
	# Opacidade reduzida se não desbloqueada
	if not achievement.get("unlocked", false):
		panel_container.modulate = Color(0.7, 0.7, 0.7, 1)
	
	achievements_list.add_child(panel_container)
	
	# Animar entrada
	panel_container.modulate.a = 0.0
	var tween = panel_container.create_tween()
	tween.tween_property(panel_container, "modulate:a", 1.0, 0.3)

func _on_voltar_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/menu.tscn")
