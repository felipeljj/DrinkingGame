extends Control

@onready var title = $VBoxContainer/Title
@onready var subtitle = $VBoxContainer/Subtitle
@onready var drinks_deck_panel = $VBoxContainer/GamesGrid/DrinksDeckPanel
@onready var never_have_i_ever_panel = $VBoxContainer/GamesGrid/NeverHaveIEverPanel
@onready var absurd_cards_panel = $VBoxContainer/GamesGrid/AbsurdCardsPanel
@onready var back_button = $VBoxContainer/BackButton

# Cores dos jogos
const DRINKS_DECK_COLOR = Color(1.0, 0.6, 0.1, 1.0)  # Laranja
const NEVER_HAVE_I_EVER_COLOR = Color(0.2, 0.5, 0.9, 1.0)  # Azul
const ABSURD_CARDS_COLOR = Color(0.1, 0.1, 0.1, 1.0)  # Preto

func _ready() -> void:
	# Adicionar partículas flutuantes
	ParticlesManager.create_bubble_particles(self)
	
	# Aplicar cores aos painéis
	_apply_panel_styles()
	
	# Animar entrada
	_animate_entrance()
	
	# Adicionar hover effects
	UIManager.add_button_hover_effect(back_button)
	
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)

func _update_ui_texts():
	if title:
		title.text = LocalizationManager.translate("hub_title", "ESCOLHA SEU JOGO")
	if subtitle:
		subtitle.text = LocalizationManager.translate("hub_subtitle", "Toque em um jogo para começar!")
	if back_button:
		back_button.text = LocalizationManager.translate("hub_back", "Voltar")
	
	# Textos dos jogos
	var drinks_name = drinks_deck_panel.get_node("VBox/Name")
	var drinks_desc = drinks_deck_panel.get_node("VBox/Description")
	if drinks_name:
		drinks_name.text = LocalizationManager.translate("game_drinks_deck", "DRINK'S DECK")
	if drinks_desc:
		drinks_desc.text = LocalizationManager.translate("game_drinks_deck_desc", "Cartas de desafios e bebidas")
	
	var never_name = never_have_i_ever_panel.get_node("VBox/Name")
	var never_desc = never_have_i_ever_panel.get_node("VBox/Description")
	if never_name:
		never_name.text = LocalizationManager.translate("game_never_have_i_ever", "EU NUNCA")
	if never_desc:
		never_desc.text = LocalizationManager.translate("game_never_have_i_ever_desc", "Quem já fez, bebe!")

	# Absurd Cards
	if absurd_cards_panel:
		var absurd_name = absurd_cards_panel.get_node_or_null("VBox/Name")
		var absurd_desc = absurd_cards_panel.get_node_or_null("VBox/Description")
		if absurd_name:
			absurd_name.text = LocalizationManager.translate("game_absurd_cards", "CARTAS ABSURDAS")
		if absurd_desc:
			absurd_desc.text = LocalizationManager.translate("game_absurd_cards_desc", "O jogo mais politicamente incorreto")

	# Coming Soon / Locked
	var coming_soon_panel = get_node_or_null("VBoxContainer/GamesGrid/ComingSoon2")
	if coming_soon_panel:
		var locked_label = coming_soon_panel.get_node_or_null("VBox/LockedLabel") # Assuming it might be different or same
		var name_label = coming_soon_panel.get_node_or_null("VBox/Name")
		var desc_label = coming_soon_panel.get_node_or_null("VBox/Description")
		
		# Se tiver label de Locked explícito
		if locked_label:
			locked_label.text = "[" + LocalizationManager.translate("pack_locked", "BLOQUEADO") + "]"
			
		# Se usar Name para mostrar "Em Breve"
		if name_label:
			name_label.text = LocalizationManager.translate("hub_coming_soon", "EM BREVE")
		if desc_label:
			desc_label.text = LocalizationManager.translate("hub_coming_soon_desc", "Novo jogo em breve!")

func _apply_panel_styles():
	# Estilo do Drink's Deck (Laranja)
	var drinks_style = StyleBoxFlat.new()
	drinks_style.bg_color = DRINKS_DECK_COLOR
	drinks_style.set_corner_radius_all(25)
	drinks_style.shadow_size = 8
	drinks_style.shadow_color = Color(DRINKS_DECK_COLOR.r, DRINKS_DECK_COLOR.g, DRINKS_DECK_COLOR.b, 0.4)
	drinks_deck_panel.add_theme_stylebox_override("panel", drinks_style)
	
	# Estilo do Eu Nunca (Azul)
	var never_style = StyleBoxFlat.new()
	never_style.bg_color = NEVER_HAVE_I_EVER_COLOR
	never_style.set_corner_radius_all(25)
	never_style.shadow_size = 8
	never_style.shadow_color = Color(NEVER_HAVE_I_EVER_COLOR.r, NEVER_HAVE_I_EVER_COLOR.g, NEVER_HAVE_I_EVER_COLOR.b, 0.4)
	never_have_i_ever_panel.add_theme_stylebox_override("panel", never_style)
	
	# Estilo do Cartas Absurdas (Preto com borda branca)
	if absurd_cards_panel:
		var absurd_style = StyleBoxFlat.new()
		absurd_style.bg_color = ABSURD_CARDS_COLOR
		absurd_style.set_corner_radius_all(25)
		absurd_style.border_width_left = 3
		absurd_style.border_width_right = 3
		absurd_style.border_width_top = 3
		absurd_style.border_width_bottom = 3
		absurd_style.border_color = Color(1, 1, 1, 1)
		absurd_cards_panel.add_theme_stylebox_override("panel", absurd_style)
	
	# Estilo dos painéis "Em Breve" (Cinza escuro)
	var coming_soon_color = Color(0.15, 0.15, 0.15, 1.0)
	var coming_soon_panels = [
		get_node_or_null("VBoxContainer/GamesGrid/ComingSoon2")
	]
	for panel in coming_soon_panels:
		if panel:
			var coming_style = StyleBoxFlat.new()
			coming_style.bg_color = coming_soon_color
			coming_style.set_corner_radius_all(25)
			coming_style.border_width_left = 2
			coming_style.border_width_right = 2
			coming_style.border_width_top = 2
			coming_style.border_width_bottom = 2
			coming_style.border_color = Color(0.3, 0.3, 0.3, 1)
			panel.add_theme_stylebox_override("panel", coming_style)
	
	# Adicionar efeitos de hover nos painéis ativos
	_setup_panel_hover(drinks_deck_panel, DRINKS_DECK_COLOR)
	_setup_panel_hover(never_have_i_ever_panel, NEVER_HAVE_I_EVER_COLOR)
	if absurd_cards_panel:
		_setup_panel_hover(absurd_cards_panel, Color(1, 1, 1, 1))

func _setup_panel_hover(panel: Control, color: Color):
	var button = panel.get_node("Button")
	if not button:
		return
	
	# Definir pivot no centro para que o scale não invada outros slots
	panel.pivot_offset = panel.size / 2
	
	button.mouse_entered.connect(func():
		if not is_instance_valid(panel) or not panel.is_inside_tree():
			return
		# Atualizar pivot caso o tamanho tenha mudado
		panel.pivot_offset = panel.size / 2
		var tween = panel.create_tween()
		if tween:
			tween.tween_property(panel, "scale", Vector2(1.03, 1.03), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	
	button.mouse_exited.connect(func():
		if not is_instance_valid(panel) or not panel.is_inside_tree():
			return
		var tween = panel.create_tween()
		if tween:
			tween.tween_property(panel, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)

func _animate_entrance():
	# Título
	title.modulate.a = 0.0
	title.position.y -= 50
	
	# Subtitle
	subtitle.modulate.a = 0.0
	
	# Painéis
	drinks_deck_panel.modulate.a = 0.0
	drinks_deck_panel.scale = Vector2(0.8, 0.8)
	
	never_have_i_ever_panel.modulate.a = 0.0
	never_have_i_ever_panel.scale = Vector2(0.8, 0.8)
	
	# Botão voltar
	back_button.modulate.a = 0.0
	
	# Animar título
	var title_tween = title.create_tween().set_parallel(true)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.5)
	title_tween.tween_property(title, "position:y", title.position.y + 50, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Subtitle com delay
	await get_tree().create_timer(0.2).timeout
	var subtitle_tween = subtitle.create_tween()
	subtitle_tween.tween_property(subtitle, "modulate:a", 1.0, 0.4)
	
	# Painéis com delay
	await get_tree().create_timer(0.1).timeout
	var drinks_tween = drinks_deck_panel.create_tween().set_parallel(true)
	drinks_tween.tween_property(drinks_deck_panel, "modulate:a", 1.0, 0.4)
	drinks_tween.tween_property(drinks_deck_panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.1).timeout
	var never_tween = never_have_i_ever_panel.create_tween().set_parallel(true)
	never_tween.tween_property(never_have_i_ever_panel, "modulate:a", 1.0, 0.4)
	never_tween.tween_property(never_have_i_ever_panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Botão voltar
	await get_tree().create_timer(0.2).timeout
	var back_tween = back_button.create_tween()
	back_tween.tween_property(back_button, "modulate:a", 1.0, 0.3)

func _on_drinks_deck_pressed() -> void:
	# Vibrar
	UIManager.safe_vibrate(50)
	
	# Partículas
	ParticlesManager.create_pulse_particles(self, drinks_deck_panel.global_position + drinks_deck_panel.size / 2, DRINKS_DECK_COLOR)
	
	# Verificar se deve mostrar aviso de idade
	var config = ConfigFile.new()
	var config_path = "user://settings.cfg"
	config.load(config_path)
	var skip_age_warning = config.get_value("settings", "skip_age_warning", false)
	
	if skip_age_warning:
		# Ir direto para seletor de packs
		UIManager.change_scene_with_fade("res://Scenes/pack_selector.tscn")
	else:
		# Mostrar aviso de idade
		_show_age_warning()

func _show_age_warning():
	# Criar overlay escuro
	var overlay = ColorRect.new()
	overlay.name = "AgeWarningOverlay"
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.z_index = 499
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	
	# Criar popup de aviso
	var viewport_size = get_viewport_rect().size
	var popup = Panel.new()
	popup.name = "AgeWarningPopup"
	popup.z_index = 500
	
	# Estilo do popup
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	style.set_corner_radius_all(25)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = Color(1, 0.6, 0.1, 1)
	popup.add_theme_stylebox_override("panel", style)
	
	# Tamanho fixo que cabe tudo
	var popup_width = min(viewport_size.x * 0.92, 950)
	var popup_height = 680
	popup.size = Vector2(popup_width, popup_height)
	popup.position = Vector2((viewport_size.x - popup_width) / 2, (viewport_size.y - popup_height) / 2)
	
	add_child(popup)
	
	# Container vertical principal - SEM SCROLL
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 40
	vbox.offset_top = 30
	vbox.offset_right = -40
	vbox.offset_bottom = -30
	vbox.add_theme_constant_override("separation", 20)
	popup.add_child(vbox)
	
	# Ícone de aviso
	var icon = Label.new()
	icon.text = "[AVISO]"
	icon.add_theme_font_size_override("font_size", 130)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(icon)
	
	# Título
	var title_label = Label.new()
	title_label.text = LocalizationManager.translate("age_warning_title", "AVISO DE IDADE")
	var title_settings = LabelSettings.new()
	title_settings.font_size = 65
	title_settings.font_color = Color(1, 0.7, 0.2, 1)
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title_label.label_settings = title_settings
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title_label)
	
	# Mensagem
	var message = Label.new()
	message.text = LocalizationManager.translate("age_warning_message", "Este jogo envolve consumo de bebidas alcoólicas.\n\nVocê precisa ser maior de idade no seu país para jogar.")
	var msg_settings = LabelSettings.new()
	msg_settings.font_size = 38
	message.label_settings = msg_settings
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(message)
	
	# Spacer flexível para empurrar checkbox e botões para baixo
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	# Checkbox customizado com ícone visível
	var checkbox_container = HBoxContainer.new()
	checkbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	checkbox_container.add_theme_constant_override("separation", 15)
	vbox.add_child(checkbox_container)
	
	# Ícone da caixinha (toggle visual)
	var checkbox_icon = Button.new()
	checkbox_icon.name = "CheckboxIcon"
	checkbox_icon.text = "☐"
	checkbox_icon.add_theme_font_size_override("font_size", 50)
	checkbox_icon.flat = true
	checkbox_icon.toggle_mode = true
	checkbox_icon.custom_minimum_size = Vector2(60, 60)
	checkbox_container.add_child(checkbox_icon)
	
	var checkbox_label = Label.new()
	checkbox_label.text = LocalizationManager.translate("age_warning_dont_show", "Não mostrar novamente")
	checkbox_label.add_theme_font_size_override("font_size", 34)
	checkbox_container.add_child(checkbox_label)
	
	# Toggle do checkbox
	checkbox_icon.toggled.connect(func(pressed):
		checkbox_icon.text = "☑" if pressed else "☐"
	)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 15
	vbox.add_child(spacer2)
	
	# Botões
	var btn_container = VBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 10)
	btn_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(btn_container)
	
	# Botão Confirmar (com estilo laranja)
	var confirm_btn = Button.new()
	confirm_btn.text = LocalizationManager.translate("age_warning_confirm", "✓  Tenho 18+ anos")
	confirm_btn.add_theme_font_size_override("font_size", 40)
	confirm_btn.custom_minimum_size = Vector2(0, 85)
	confirm_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var confirm_style = StyleBoxFlat.new()
	confirm_style.bg_color = Color(1, 0.6, 0.1, 1)
	confirm_style.set_corner_radius_all(20)
	confirm_style.content_margin_left = 60
	confirm_style.content_margin_right = 60
	confirm_btn.add_theme_stylebox_override("normal", confirm_style)
	
	var confirm_hover = StyleBoxFlat.new()
	confirm_hover.bg_color = Color(1, 0.7, 0.2, 1)
	confirm_hover.set_corner_radius_all(20)
	confirm_hover.content_margin_left = 60
	confirm_hover.content_margin_right = 60
	confirm_btn.add_theme_stylebox_override("hover", confirm_hover)
	confirm_btn.add_theme_stylebox_override("pressed", confirm_style)
	
	confirm_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	confirm_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	confirm_btn.add_theme_color_override("font_pressed_color", Color(0.2, 0.2, 0.2, 1))
	
	confirm_btn.pressed.connect(func():
		# Salvar preferência se checkbox marcado
		if checkbox_icon.button_pressed:
			var config = ConfigFile.new()
			var config_path = "user://settings.cfg"
			config.load(config_path)
			config.set_value("settings", "skip_age_warning", true)
			config.save(config_path)
		
		# Fechar popup e overlay, ir para o jogo
		overlay.queue_free()
		popup.queue_free()
		UIManager.change_scene_with_fade("res://Scenes/pack_selector.tscn")
	)
	btn_container.add_child(confirm_btn)
	
	# Botão Cancelar
	var cancel_btn = Button.new()
	cancel_btn.text = LocalizationManager.translate("age_warning_cancel", "Voltar")
	cancel_btn.add_theme_font_size_override("font_size", 36)
	cancel_btn.custom_minimum_size = Vector2(0, 60)
	cancel_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cancel_btn.flat = true
	cancel_btn.pressed.connect(func():
		overlay.queue_free()
		popup.queue_free()
	)
	btn_container.add_child(cancel_btn)
	

	
	# Animação de entrada
	overlay.modulate.a = 0.0
	popup.modulate.a = 0.0
	popup.scale = Vector2(0.9, 0.9)
	popup.pivot_offset = popup.size / 2
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_never_have_i_ever_pressed() -> void:
	# Vibrar
	UIManager.safe_vibrate(50)
	
	# Partículas
	ParticlesManager.create_pulse_particles(self, never_have_i_ever_panel.global_position + never_have_i_ever_panel.size / 2, NEVER_HAVE_I_EVER_COLOR)
	
	# Ir para seletor de packs do Eu Nunca
	UIManager.change_scene_with_fade("res://Scenes/never_have_i_ever_selector.tscn")

func _on_absurd_cards_pressed() -> void:
	# Vibrar
	UIManager.safe_vibrate(50)
	
	# Partículas
	if absurd_cards_panel:
		ParticlesManager.create_pulse_particles(self, absurd_cards_panel.global_position + absurd_cards_panel.size / 2, Color(1, 1, 1, 1))
	
	# Mostrar aviso de conteúdo
	_show_content_warning()

func _show_content_warning():
	# Verificar se deve pular o aviso
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		if config.get_value("content_warning", "skip", false):
			UIManager.change_scene_with_fade("res://Scenes/absurd_cards_lobby.tscn")
			return
	
	# Criar overlay escuro
	var overlay = ColorRect.new()
	overlay.name = "ContentWarningOverlay"
	overlay.color = Color(0, 0, 0, 0.9)
	overlay.z_index = 499
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	
	# Criar popup de aviso
	var viewport_size = get_viewport_rect().size
	var popup = Panel.new()
	popup.name = "ContentWarningPopup"
	popup.z_index = 500
	
	# Estilo do popup (preto com borda branca)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	style.set_corner_radius_all(25)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = Color(1, 1, 1, 1)
	popup.add_theme_stylebox_override("panel", style)
	
	# Tamanho - ajustado para caber na tela
	var popup_width = min(viewport_size.x * 0.9, 800)
	var popup_height = min(viewport_size.y * 0.85, 900)
	popup.size = Vector2(popup_width, popup_height)
	popup.position = Vector2((viewport_size.x - popup_width) / 2, (viewport_size.y - popup_height) / 2)
	
	add_child(popup)
	
	# Container vertical
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 30
	vbox.offset_top = 20
	vbox.offset_right = -30
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 15)
	popup.add_child(vbox)
	
	# Ícone de aviso
	var icon = Label.new()
	icon.text = "[AVISO]"
	icon.add_theme_font_size_override("font_size", 80)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(icon)
	
	# Título
	var title_label = Label.new()
	title_label.text = LocalizationManager.translate("content_warning_title", "AVISO DE CONTEÚDO")
	var title_settings = LabelSettings.new()
	title_settings.font_size = 44
	title_settings.font_color = Color(1, 1, 1, 1)
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title_label.label_settings = title_settings
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(title_label)
	
	# Mensagem
	var message = Label.new()
	message.text = LocalizationManager.translate("content_warning_message", "Este jogo contém conteúdo PESADO...")
	var msg_settings = LabelSettings.new()
	msg_settings.font_size = 28
	message.label_settings = msg_settings
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(message)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)
	
	# Checkbox customizado com ícone visível (igual ao popup de idade)
	var checkbox_container = HBoxContainer.new()
	checkbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	checkbox_container.add_theme_constant_override("separation", 15)
	vbox.add_child(checkbox_container)
	
	# Ícone da caixinha (toggle visual)
	var checkbox_icon = Button.new()
	checkbox_icon.name = "CheckboxIcon"
	checkbox_icon.text = "☐"
	checkbox_icon.add_theme_font_size_override("font_size", 50)
	checkbox_icon.flat = true
	checkbox_icon.toggle_mode = true
	checkbox_icon.custom_minimum_size = Vector2(60, 60)
	checkbox_container.add_child(checkbox_icon)
	
	var checkbox_label = Label.new()
	checkbox_label.text = LocalizationManager.translate("content_warning_dont_show", "Não mostrar novamente")
	checkbox_label.add_theme_font_size_override("font_size", 30)
	checkbox_container.add_child(checkbox_label)
	
	# Toggle do checkbox
	checkbox_icon.toggled.connect(func(pressed):
		checkbox_icon.text = "☑" if pressed else "☐"
	)
	
	# Botões
	var btn_container = VBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 12)
	btn_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(btn_container)
	
	# Botão Confirmar (branco)
	var confirm_btn = Button.new()
	confirm_btn.text = LocalizationManager.translate("content_warning_confirm", "✓  Entendi e quero jogar")
	confirm_btn.add_theme_font_size_override("font_size", 32)
	confirm_btn.custom_minimum_size = Vector2(0, 70)
	confirm_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var confirm_style = StyleBoxFlat.new()
	confirm_style.bg_color = Color(1, 1, 1, 1)
	confirm_style.set_corner_radius_all(20)
	confirm_style.content_margin_left = 40
	confirm_style.content_margin_right = 40
	confirm_btn.add_theme_stylebox_override("normal", confirm_style)
	confirm_btn.add_theme_stylebox_override("hover", confirm_style)
	confirm_btn.add_theme_stylebox_override("pressed", confirm_style)
	confirm_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	confirm_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	confirm_btn.add_theme_color_override("font_pressed_color", Color(0.3, 0.3, 0.3, 1))
	
	confirm_btn.pressed.connect(func():
		# Salvar preferência se checkbox marcado
		if checkbox_icon.button_pressed:
			var cfg = ConfigFile.new()
			cfg.load("user://settings.cfg")
			cfg.set_value("content_warning", "skip", true)
			cfg.save("user://settings.cfg")
		overlay.queue_free()
		popup.queue_free()
		UIManager.change_scene_with_fade("res://Scenes/absurd_cards_lobby.tscn")
	)
	btn_container.add_child(confirm_btn)
	
	# Botão Cancelar
	var cancel_btn = Button.new()
	cancel_btn.text = LocalizationManager.translate("content_warning_cancel", "Voltar")
	cancel_btn.add_theme_font_size_override("font_size", 30)
	cancel_btn.custom_minimum_size = Vector2(0, 50)
	cancel_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cancel_btn.flat = true
	cancel_btn.pressed.connect(func():
		overlay.queue_free()
		popup.queue_free()
	)
	btn_container.add_child(cancel_btn)
	
	# Animação de entrada
	overlay.modulate.a = 0.0
	popup.modulate.a = 0.0
	popup.scale = Vector2(0.9, 0.9)
	popup.pivot_offset = popup.size / 2
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_back_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/menu.tscn")
