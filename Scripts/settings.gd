extends Control

@onready var vibration_toggle = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/VibrationCard/VibrationMargin/VibrationContainer/VibrationToggle
@onready var repeat_cards_toggle = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/RepeatCard/RepeatMargin/RepeatCardsContainer/RepeatCardsToggle
@onready var font_size_option = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/FontCard/FontMargin/FontSizeContainer/FontSizeOption
@onready var language_option = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/LanguageCard/LanguageMargin/LanguageContainer/LanguageOption
@onready var debug_button = $Panel/VBoxContainer/DebugButton
@onready var close_button = $Panel/VBoxContainer/CloseButton
@onready var panel = $Panel
@onready var title_label = $Panel/VBoxContainer/TitleContainer/Title
@onready var vibration_label = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/VibrationCard/VibrationMargin/VibrationContainer/VibrationVBox/VibrationLabel
@onready var repeat_cards_label = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/RepeatCard/RepeatMargin/RepeatCardsContainer/RepeatVBox/RepeatCardsLabel
@onready var font_size_label = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/FontCard/FontMargin/FontSizeContainer/FontVBox/FontSizeLabel
@onready var language_label = $Panel/VBoxContainer/ScrollContainer/SettingsVBox/LanguageCard/LanguageMargin/LanguageContainer/LanguageVBox/LanguageLabel

func _ready():
	# Carregar estados das configurações
	var vibration_enabled = UIManager.is_vibration_enabled()
	vibration_toggle.button_pressed = vibration_enabled
	
	var repeat_cards_enabled = UIManager.is_card_repeat_allowed()
	repeat_cards_toggle.button_pressed = repeat_cards_enabled
	
	# Configurar OptionButton de tamanho de fonte
	font_size_option.clear()
	font_size_option.add_item(LocalizationManager.translate("settings_font_size_small", "Pequena"))
	font_size_option.add_item(LocalizationManager.translate("settings_font_size_normal", "Normal"))
	font_size_option.add_item(LocalizationManager.translate("settings_font_size_large", "Grande"))
	font_size_option.add_item(LocalizationManager.translate("settings_font_size_extra_large", "Extra Grande"))
	
	# Definir seleção baseada no multiplicador atual
	var current_multiplier = UIManager.get_font_size_multiplier()
	if current_multiplier == UIManager.FONT_SIZE_SMALL:
		font_size_option.selected = 0
	elif current_multiplier == UIManager.FONT_SIZE_NORMAL:
		font_size_option.selected = 1
	elif current_multiplier == UIManager.FONT_SIZE_LARGE:
		font_size_option.selected = 2
	elif current_multiplier == UIManager.FONT_SIZE_EXTRA_LARGE:
		font_size_option.selected = 3
	else:
		font_size_option.selected = 1  # Padrão: Normal
	
	# Configurar OptionButton de idioma
	language_option.clear()
	language_option.add_item(LocalizationManager.translate("settings_language_pt", "Português"))
	language_option.add_item(LocalizationManager.translate("settings_language_en", "English"))
	language_option.add_item(LocalizationManager.translate("settings_language_es", "Español"))
	
	# Definir seleção baseada no idioma atual
	var current_lang = UIManager.get_language()
	if current_lang == "pt":
		language_option.selected = 0
	elif current_lang == "en":
		language_option.selected = 1
	elif current_lang == "es":
		language_option.selected = 2
	else:
		language_option.selected = 0  # Padrão: Português
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_on_language_changed)
	
	# Atualizar textos com traduções
	_update_texts()
	
	# Adicionar hover effects
	UIManager.add_button_hover_effect(debug_button)
	UIManager.add_button_hover_effect(close_button)
	
	# Estilizar os dropdowns
	_style_option_buttons()
	
	# Animar entrada
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	var tween = panel.create_tween()
	if tween:
		tween.set_parallel(true)
		tween.tween_property(panel, "modulate:a", 1.0, 0.3)
		tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	UIManager.safe_vibrate(50)

func _style_option_buttons():
	# Estilo para os OptionButtons
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.15, 0.2, 1)
	btn_style.set_corner_radius_all(12)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(0.4, 0.5, 0.7, 0.6)
	
	for option_btn in [font_size_option, language_option]:
		if option_btn:
			option_btn.add_theme_stylebox_override("normal", btn_style)
			option_btn.add_theme_stylebox_override("hover", btn_style)
			option_btn.add_theme_stylebox_override("pressed", btn_style)
			option_btn.add_theme_stylebox_override("focus", btn_style)
			option_btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			option_btn.add_theme_color_override("font_hover_color", Color(0.7, 0.85, 1, 1))
			
			# Estilizar o popup do dropdown
			var popup = option_btn.get_popup()
			if popup:
				popup.add_theme_font_size_override("font_size", 38)
				popup.add_theme_color_override("font_color", Color(1, 1, 1, 1))
				popup.add_theme_color_override("font_hover_color", Color(0.3, 0.6, 1, 1))
				
				var popup_style = StyleBoxFlat.new()
				popup_style.bg_color = Color(0.1, 0.1, 0.15, 0.98)
				popup_style.set_corner_radius_all(15)
				popup_style.border_width_left = 2
				popup_style.border_width_right = 2
				popup_style.border_width_top = 2
				popup_style.border_width_bottom = 2
				popup_style.border_color = Color(0.4, 0.5, 0.7, 0.6)
				popup_style.content_margin_left = 20
				popup_style.content_margin_right = 20
				popup_style.content_margin_top = 15
				popup_style.content_margin_bottom = 15
				popup.add_theme_stylebox_override("panel", popup_style)
				
				var hover_style = StyleBoxFlat.new()
				hover_style.bg_color = Color(0.25, 0.35, 0.55, 1)
				hover_style.set_corner_radius_all(8)
				popup.add_theme_stylebox_override("hover", hover_style)

func _update_texts():
	if title_label:
		title_label.text = LocalizationManager.translate("settings_title", "CONFIGURAÇÕES")
	if vibration_label:
		vibration_label.text = LocalizationManager.translate("settings_vibration", "Vibração:")
	if vibration_toggle:
		vibration_toggle.text = LocalizationManager.translate("settings_vibration_enabled", "Ativada")
	if repeat_cards_label:
		repeat_cards_label.text = LocalizationManager.translate("settings_repeat_cards", "Repetir Cartas:")
	if repeat_cards_toggle:
		repeat_cards_toggle.text = LocalizationManager.translate("settings_repeat_cards_enabled", "Permitir")
	if font_size_label:
		font_size_label.text = LocalizationManager.translate("settings_font_size", "Tamanho da Fonte:")
	if language_label:
		language_label.text = LocalizationManager.translate("settings_language", "Idioma:")
	if debug_button:
		debug_button.text = LocalizationManager.translate("settings_debug_menu", "🐛 DEBUG MENU")
	if close_button:
		close_button.text = LocalizationManager.translate("settings_close", "FECHAR")
	
	# Atualizar opções do OptionButton de fonte
	if font_size_option:
		font_size_option.set_item_text(0, LocalizationManager.translate("settings_font_size_small", "Pequena"))
		font_size_option.set_item_text(1, LocalizationManager.translate("settings_font_size_normal", "Normal"))
		font_size_option.set_item_text(2, LocalizationManager.translate("settings_font_size_large", "Grande"))
		font_size_option.set_item_text(3, LocalizationManager.translate("settings_font_size_extra_large", "Extra Grande"))
	
	# Atualizar opções do OptionButton de idioma
	if language_option:
		language_option.set_item_text(0, LocalizationManager.translate("settings_language_pt", "Português"))
		language_option.set_item_text(1, LocalizationManager.translate("settings_language_en", "English"))
		language_option.set_item_text(2, LocalizationManager.translate("settings_language_es", "Español"))

func _on_language_changed(_new_language: String):
	_update_texts()

func _on_vibration_toggled(button_pressed: bool):
	UIManager.set_vibration_enabled(button_pressed)
	if button_pressed:
		UIManager.safe_vibrate(50)

func _on_repeat_cards_toggled(button_pressed: bool):
	UIManager.set_allow_card_repeat(button_pressed)
	UIManager.safe_vibrate(30)

func _on_font_size_selected(index: int):
	var multiplier: float
	match index:
		0:
			multiplier = UIManager.FONT_SIZE_SMALL
		1:
			multiplier = UIManager.FONT_SIZE_NORMAL
		2:
			multiplier = UIManager.FONT_SIZE_LARGE
		3:
			multiplier = UIManager.FONT_SIZE_EXTRA_LARGE
		_:
			multiplier = UIManager.FONT_SIZE_NORMAL
	
	UIManager.set_font_size(multiplier)
	UIManager.safe_vibrate(30)

func _on_language_selected(index: int):
	var lang: String
	match index:
		0:
			lang = "pt"
		1:
			lang = "en"
		2:
			lang = "es"
		_:
			lang = "pt"
	
	UIManager.set_language(lang)
	UIManager.safe_vibrate(30)

func _on_debug_button_pressed():
	UIManager.toggle_debug_menu()
	UIManager.safe_vibrate(100)

func _on_close_pressed():
	# Animar saída
	var tween = panel.create_tween()
	if tween:
		tween.set_parallel(true)
		tween.tween_property(panel, "modulate:a", 0.0, 0.2)
		tween.tween_property(panel, "scale", Vector2(0.8, 0.8), 0.2)
		await tween.finished
	
	get_tree().queue_delete(self)
