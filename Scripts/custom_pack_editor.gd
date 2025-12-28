extends Control

# Referências aos nodes - Tab Criar
@onready var criar_tab = $MainVBox/TabContent/CriarTab
@onready var gerenciar_tab = $MainVBox/TabContent/GerenciarTab
@onready var tab_criar_btn = $MainVBox/TabButtons/TabCriar
@onready var tab_gerenciar_btn = $MainVBox/TabButtons/TabGerenciar

@onready var name_input: LineEdit = $MainVBox/TabContent/CriarTab/CriarVBox/NameCard/NameSection/NameMargin/NameVBox/NameInput
@onready var color_button: ColorPickerButton = $MainVBox/TabContent/CriarTab/CriarVBox/ColorCard/ColorSection/ColorMargin/ColorVBox/ColorPreview/ColorButton
@onready var color_preview: Panel = $MainVBox/TabContent/CriarTab/CriarVBox/ColorCard/ColorSection/ColorMargin/ColorVBox/ColorPreview
@onready var cards_input: TextEdit = $MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/CardsInput
@onready var char_counter: Label = $MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/CharCounter

# Tab Gerenciar
@onready var gerenciar_vbox: VBoxContainer = $MainVBox/TabContent/GerenciarTab/GerenciarVBox
@onready var empty_label: Label = $MainVBox/TabContent/GerenciarTab/GerenciarVBox/EmptyLabel

# Estado
var current_color: Color = Color("#FF6B9D")
var current_tab: String = "criar"

func _ready():
	# Configurar cor inicial
	color_button.color = current_color
	_update_color_preview()
	
	# Aplicar estilos
	_apply_styles()
	
	# Emojis restaurados - não remover mais
	
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Adicionar hover effects nos botões
	UIManager.add_button_hover_effect($MainVBox/TabContent/CriarTab/CriarVBox/SaveButton)
	UIManager.add_button_hover_effect($MainVBox/BackButton)
	UIManager.add_button_hover_effect(tab_criar_btn)
	UIManager.add_button_hover_effect(tab_gerenciar_btn)
	
	# Animar entrada
	_animate_entrance()
	
	# Configurar tab inicial
	_switch_tab("criar")
	
	# Focus no nome (com delay para garantir que funciona no browser)
	call_deferred("_setup_input_focus")
	
	# Configurar inputs para funcionar no browser
	_setup_browser_inputs()

func _update_ui_texts():
	# Atualizar textos das tabs
	if tab_criar_btn:
		tab_criar_btn.text = LocalizationManager.translate("custom_pack_tab_create", "Criar Pack")
	if tab_gerenciar_btn:
		tab_gerenciar_btn.text = LocalizationManager.translate("custom_pack_tab_manage", "Meus Packs")
	
	# Atualizar labels de seções
	if has_node("MainVBox/TabContent/CriarTab/CriarVBox/NameCard/NameSection/NameMargin/NameVBox/NameLabel"):
		$MainVBox/TabContent/CriarTab/CriarVBox/NameCard/NameSection/NameMargin/NameVBox/NameLabel.text = LocalizationManager.translate("custom_pack_name_label", "Nome do Pack")
	if has_node("MainVBox/TabContent/CriarTab/CriarVBox/ColorCard/ColorSection/ColorMargin/ColorVBox/ColorLabel"):
		$MainVBox/TabContent/CriarTab/CriarVBox/ColorCard/ColorSection/ColorMargin/ColorVBox/ColorLabel.text = LocalizationManager.translate("custom_pack_color_label", "Cor do Pack")
	if has_node("MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/CardsLabel"):
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/CardsLabel.text = LocalizationManager.translate("custom_pack_your_cards", "Suas Cartas")
	
	# Hint de cartas
	if has_node("MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/CardsHint"):
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/CardsHint.text = LocalizationManager.translate("custom_pack_cards_hint", "Uma carta por linha (aperte enter para começar uma nova)")
	
	# Placeholders
	if name_input:
		name_input.placeholder_text = LocalizationManager.translate("custom_pack_name_placeholder", "Ex: Festa da Gabi")
	if cards_input:
		cards_input.placeholder_text = LocalizationManager.translate("custom_pack_cards_placeholder", "Todos os solteiros bebem\nO mais engraçado da roda bebe 2x\nConte uma história embaraçosa")
	
	# Botão de cor
	if has_node("MainVBox/TabContent/CriarTab/CriarVBox/ColorCard/ColorSection/ColorMargin/ColorVBox/ColorPreview/ColorButton"):
		$MainVBox/TabContent/CriarTab/CriarVBox/ColorCard/ColorSection/ColorMargin/ColorVBox/ColorPreview/ColorButton.text = LocalizationManager.translate("custom_pack_choose_color", "Escolher Cor")
	
	# Botão salvar
	if has_node("MainVBox/TabContent/CriarTab/CriarVBox/SaveButton"):
		$MainVBox/TabContent/CriarTab/CriarVBox/SaveButton.text = LocalizationManager.translate("custom_pack_save_button", "SALVAR PACK")
	
	# Texto da lista vazia
	if empty_label:
		empty_label.text = LocalizationManager.translate("custom_pack_empty_list", "Nenhum pack criado ainda\nVá para 'Criar Pack' para começar!")
	
	# Botão voltar
	if has_node("MainVBox/BackButton"):
		$MainVBox/BackButton.text = LocalizationManager.translate("pack_selector_back", "Voltar")

func _animate_entrance():
	var main_vbox = $MainVBox
	if not main_vbox or not is_instance_valid(main_vbox):
		return
	
	main_vbox.modulate.a = 0.0
	main_vbox.scale = Vector2(0.95, 0.95)
	
	var tween = main_vbox.create_tween().set_parallel(true)
	tween.tween_property(main_vbox, "modulate:a", 1.0, 0.4)
	tween.tween_property(main_vbox, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _apply_styles():
	# Estilo do campo de nome
	var name_style = StyleBoxFlat.new()
	name_style.bg_color = Color(0.15, 0.15, 0.15, 1)
	name_style.set_corner_radius_all(15)
	name_style.border_width_left = 3
	name_style.border_width_right = 3
	name_style.border_width_top = 3
	name_style.border_width_bottom = 3
	name_style.border_color = Color(0.3, 0.3, 0.3, 1)
	name_input.add_theme_stylebox_override("normal", name_style)
	name_input.add_theme_stylebox_override("focus", name_style)
	
	# Estilo do preview da cor
	_update_color_preview()
	
	# Estilo do TextEdit (cartas)
	var cards_style = StyleBoxFlat.new()
	cards_style.bg_color = Color(0.12, 0.12, 0.12, 1)
	cards_style.set_corner_radius_all(20)
	cards_style.border_width_left = 3
	cards_style.border_width_right = 3
	cards_style.border_width_top = 3
	cards_style.border_width_bottom = 3
	cards_style.border_color = Color(0.3, 0.9, 0.3, 1)
	cards_style.content_margin_left = 20
	cards_style.content_margin_right = 20
	cards_style.content_margin_top = 20
	cards_style.content_margin_bottom = 20
	cards_input.add_theme_stylebox_override("normal", cards_style)
	cards_input.add_theme_stylebox_override("focus", cards_style)
	
	# Estilo dos botões de emoji
	var emoji_buttons = [
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/EmojiRow/Emoji1,
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/EmojiRow/Emoji2,
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/EmojiRow/Emoji3,
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/EmojiRow/Emoji4,
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/EmojiRow/Emoji5,
		$MainVBox/TabContent/CriarTab/CriarVBox/CardsCard/CardsSection/CardsMargin/CardsVBox/EmojiRow/Emoji6
	]
	
	var emojis = []  # Emojis removidos para compatibilidade web
	# Só configura os botões de emoji se houver emojis definidos
	if emojis.size() > 0:
		for i in range(min(emoji_buttons.size(), emojis.size())):
			var btn = emoji_buttons[i]
			if btn:
				var emoji = emojis[i]
				var emoji_style = StyleBoxFlat.new()
				emoji_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
				emoji_style.set_corner_radius_all(15)
				btn.add_theme_stylebox_override("normal", emoji_style)
				btn.add_theme_stylebox_override("hover", emoji_style)
				btn.add_theme_stylebox_override("pressed", emoji_style)
				UIManager.add_button_hover_effect(btn)
				btn.pressed.connect(func(): _on_emoji_pressed(emoji))
	
	# Estilo do botão salvar
	var save_style = StyleBoxFlat.new()
	save_style.bg_color = Color(0.2, 0.8, 0.3, 1)
	save_style.set_corner_radius_all(20)
	save_style.shadow_size = 10
	save_style.shadow_color = Color(0, 0, 0, 0.3)
	$MainVBox/TabContent/CriarTab/CriarVBox/SaveButton.add_theme_stylebox_override("normal", save_style)
	$MainVBox/TabContent/CriarTab/CriarVBox/SaveButton.add_theme_stylebox_override("hover", save_style)
	$MainVBox/TabContent/CriarTab/CriarVBox/SaveButton.add_theme_stylebox_override("pressed", save_style)

func _setup_browser_inputs():
	# Configurar inputs para funcionar corretamente no browser
	if OS.get_name() == "Web":
		# No browser, garantir que os inputs podem receber foco e input
		if name_input:
			name_input.focus_mode = Control.FOCUS_ALL
			name_input.mouse_filter = Control.MOUSE_FILTER_STOP
			name_input.editable = true
			# Conectar evento de clique para garantir foco
			if not name_input.gui_input.is_connected(_on_name_input_clicked):
				name_input.gui_input.connect(_on_name_input_clicked)
			# Conectar evento de texto mudado para garantir que funciona
			if not name_input.text_changed.is_connected(_on_name_changed):
				name_input.text_changed.connect(_on_name_changed)
		
		if cards_input:
			cards_input.focus_mode = Control.FOCUS_ALL
			cards_input.mouse_filter = Control.MOUSE_FILTER_STOP
			cards_input.editable = true
			# Conectar evento de clique para garantir foco
			if not cards_input.gui_input.is_connected(_on_cards_input_clicked):
				cards_input.gui_input.connect(_on_cards_input_clicked)
			# Conectar evento de texto mudado
			if not cards_input.text_changed.is_connected(_on_cards_text_changed):
				cards_input.text_changed.connect(_on_cards_text_changed)

func _on_name_input_clicked(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		name_input.grab_focus()
		# Forçar foco no browser
		if OS.get_name() == "Web":
			call_deferred("_force_focus", name_input)

func _on_cards_input_clicked(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		cards_input.grab_focus()
		# Forçar foco no browser
		if OS.get_name() == "Web":
			call_deferred("_force_focus", cards_input)

func _force_focus(control: Control):
	if control and is_instance_valid(control):
		control.grab_focus()
		# Múltiplas tentativas para garantir
		await get_tree().process_frame
		control.grab_focus()

# Função removida - emojis restaurados

func _setup_input_focus():
	# Tentar dar foco no campo de nome
	if name_input and is_instance_valid(name_input):
		# Múltiplas tentativas para garantir que funciona no browser
		name_input.grab_focus()
		await get_tree().process_frame
		name_input.grab_focus()
		await get_tree().create_timer(0.1).timeout
		name_input.grab_focus()

func _switch_tab(tab_name: String):
	current_tab = tab_name
	
	if tab_name == "criar":
		criar_tab.visible = true
		gerenciar_tab.visible = false
		_style_active_tab(tab_criar_btn, true)
		_style_active_tab(tab_gerenciar_btn, false)
	else:
		criar_tab.visible = false
		gerenciar_tab.visible = true
		_style_active_tab(tab_criar_btn, false)
		_style_active_tab(tab_gerenciar_btn, true)
		_refresh_pack_list()

func _style_active_tab(btn: Button, is_active: bool):
	var style = StyleBoxFlat.new()
	if is_active:
		style.bg_color = Color(0.3, 0.6, 0.9, 1)
	else:
		style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	style.set_corner_radius_all(15)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)

func _on_tab_criar_pressed():
	_switch_tab("criar")

func _on_tab_gerenciar_pressed():
	_switch_tab("gerenciar")

func _refresh_pack_list():
	# Limpar lista antiga
	for child in gerenciar_vbox.get_children():
		if child != empty_label:
			child.queue_free()
	
	# Carregar packs
	var packs = _load_all_packs()
	
	if packs.size() == 0:
		empty_label.visible = true
	else:
		empty_label.visible = false
		
		for pack in packs:
			_add_pack_item(pack)

func _add_pack_item(pack: Dictionary):
	# Container principal (cada pack é um card)
	var card_margin = MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 0)
	card_margin.add_theme_constant_override("margin_right", 0)
	card_margin.add_theme_constant_override("margin_top", 10)
	card_margin.add_theme_constant_override("margin_bottom", 10)
	gerenciar_vbox.add_child(card_margin)
	
	var card_panel = Panel.new()
	card_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	card_panel.custom_minimum_size = Vector2(0, 160)
	card_margin.add_child(card_panel)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(pack.get("color", "#f475c5"))
	card_style.set_corner_radius_all(28)
	card_style.shadow_size = 16
	card_style.shadow_color = Color(0, 0, 0, 0.35)
	card_panel.add_theme_stylebox_override("panel", card_style)
	
	# Conteúdo interno com margens
	var inner = MarginContainer.new()
	inner.add_theme_constant_override("margin_left", 36)
	inner.add_theme_constant_override("margin_right", 36)
	inner.add_theme_constant_override("margin_top", 28)
	inner.add_theme_constant_override("margin_bottom", 28)
	card_panel.add_child(inner)
	
	var content = HBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 32)
	inner.add_child(content)
	
	# Ícone do pack (SVG)
	var icon_container = CenterContainer.new()
	icon_container.custom_minimum_size = Vector2(80, 80)
	content.add_child(icon_container)
	
	var icon = TextureRect.new()
	icon.texture = load("res://icons/customized.svg")
	icon.custom_minimum_size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_container.add_child(icon)
	
	# Informações (nome + detalhes)
	var info_box = VBoxContainer.new()
	info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_box.add_theme_constant_override("separation", 6)
	content.add_child(info_box)
	
	var name_label = Label.new()
	name_label.text = pack.get("name", LocalizationManager.translate("custom_pack_default_name", "Pack Personalizado"))
	var name_ls = LabelSettings.new()
	name_ls.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	name_ls.font_size = 48
	name_ls.font_color = Color.BLACK
	name_ls.outline_size = 3
	name_ls.outline_color = Color(1, 1, 1, 0.45)
	name_label.label_settings = name_ls
	info_box.add_child(name_label)
	
	var meta_label = Label.new()
	var cards_count = pack.get("cards", []).size()
	if cards_count == 1:
		meta_label.text = LocalizationManager.translate("custom_pack_card_singular", "%d carta") % cards_count
	else:
		meta_label.text = LocalizationManager.translate("custom_pack_card_plural", "%d cartas") % cards_count
	var meta_ls = LabelSettings.new()
	meta_ls.font_size = 30
	meta_ls.font_color = Color(0, 0, 0, 0.85)
	meta_label.label_settings = meta_ls
	info_box.add_child(meta_label)
	
	# Botão deletar
	var delete_btn = Button.new()
	delete_btn.text = LocalizationManager.translate("custom_pack_delete", "Deletar")
	delete_btn.icon = load("res://icons/icon_trash.svg") if ResourceLoader.exists("res://icons/icon_trash.svg") else null
	delete_btn.custom_minimum_size = Vector2(200, 90)
	delete_btn.focus_mode = Control.FOCUS_NONE
	delete_btn.tooltip_text = "Remover este pack"
	delete_btn.add_theme_color_override("font_color", Color(0, 0, 0))
	delete_btn.add_theme_color_override("font_color_hover", Color(0, 0, 0))
	delete_btn.add_theme_color_override("font_color_pressed", Color(0, 0, 0))
	delete_btn.add_theme_color_override("font_color_disabled", Color(0, 0, 0, 0.4))
	
	var delete_normal = StyleBoxFlat.new()
	delete_normal.bg_color = Color(1, 1, 1, 0.85)
	delete_normal.set_corner_radius_all(22)
	delete_normal.shadow_size = 6
	delete_normal.shadow_color = Color(0, 0, 0, 0.25)
	delete_btn.add_theme_stylebox_override("normal", delete_normal)
	
	var delete_hover = StyleBoxFlat.new()
	delete_hover.bg_color = Color(0.9, 0.2, 0.2, 1)
	delete_hover.set_corner_radius_all(22)
	delete_hover.shadow_size = 10
	delete_hover.shadow_color = Color(0.7, 0, 0, 0.5)
	delete_btn.add_theme_stylebox_override("hover", delete_hover)
	delete_btn.add_theme_stylebox_override("pressed", delete_hover)
	
	delete_btn.add_theme_font_size_override("font_size", 32)
	content.add_child(delete_btn)
	UIManager.add_button_hover_effect(delete_btn)
	
	delete_btn.pressed.connect(func():
		_on_pack_delete_pressed(pack.get("name", ""))
	)
	
	# Hover suave no card inteiro
	card_panel.mouse_entered.connect(func():
		card_panel.modulate = Color(1.05, 1.05, 1.05, 1)
	)
	card_panel.mouse_exited.connect(func():
		card_panel.modulate = Color(1, 1, 1, 1)
	)
	
	UIManager.animate_panel_entrance(card_panel)

func _on_pack_delete_pressed(pack_name: String):
	_show_delete_confirmation(pack_name)

func _on_name_changed(new_text: String):
	pass

func _on_color_changed(color: Color):
	current_color = color
	_update_color_preview()

func _update_color_preview():
	# Atualizar preview da cor
	var color_prev_style = StyleBoxFlat.new()
	color_prev_style.bg_color = current_color
	color_prev_style.set_corner_radius_all(20)
	color_prev_style.shadow_size = 15
	color_prev_style.shadow_color = Color(current_color.r, current_color.g, current_color.b, 0.5)
	color_preview.add_theme_stylebox_override("panel", color_prev_style)
	
	# Animar preview
	UIManager.pulse_element(color_preview, 1.1, 0.3)

func _on_cards_text_changed():
	_update_char_counter()
	_update_validation()

func _update_char_counter():
	var lines = cards_input.text.split("\n")
	var max_chars = 0
	var total_cards = 0
	
	for line in lines:
		var stripped = line.strip_edges()
		if stripped != "":
			total_cards += 1
			if stripped.length() > max_chars:
				max_chars = stripped.length()
	
	char_counter.text = LocalizationManager.translate("custom_pack_char_counter", "%d cartas | Maior: %d chars") % [total_cards, max_chars]
	
	# Cor baseada em tamanho
	if max_chars > 250:
		char_counter.modulate = Color(0.9, 0.1, 0.1, 1)  # Vermelho
	elif max_chars > 180:
		char_counter.modulate = Color(0.9, 0.7, 0.1, 1)  # Amarelo
	else:
		char_counter.modulate = Color(0.3, 0.9, 0.3, 1)  # Verde

func _update_validation():
	var lines = cards_input.text.split("\n")
	var max_chars = 0
	
	for line in lines:
		var stripped = line.strip_edges()
		if stripped != "" and stripped.length() > max_chars:
			max_chars = stripped.length()
	
	# Mudar borda do TextEdit
	var cards_style = StyleBoxFlat.new()
	cards_style.bg_color = Color(0.12, 0.12, 0.12, 1)
	cards_style.set_corner_radius_all(20)
	cards_style.border_width_left = 3
	cards_style.border_width_right = 3
	cards_style.border_width_top = 3
	cards_style.border_width_bottom = 3
	cards_style.content_margin_left = 20
	cards_style.content_margin_right = 20
	cards_style.content_margin_top = 20
	cards_style.content_margin_bottom = 20
	
	if max_chars > 250:
		cards_style.border_color = Color(0.9, 0.1, 0.1, 1)  # Vermelho
	elif max_chars > 180:
		cards_style.border_color = Color(0.9, 0.7, 0.1, 1)  # Amarelo
	else:
		cards_style.border_color = Color(0.3, 0.9, 0.3, 1)  # Verde
	
	cards_input.add_theme_stylebox_override("normal", cards_style)
	cards_input.add_theme_stylebox_override("focus", cards_style)

func _on_emoji_pressed(emoji: String):
	cards_input.insert_text_at_caret(emoji)
	cards_input.grab_focus()
	
	# Feedback visual
	UIManager.safe_vibrate(30)

func _on_save_pressed():
	var pack = _build_pack_dict()
	
	# Validar
	if pack.get("name", "") == "":
		_show_toast(LocalizationManager.translate("custom_pack_error_no_name", "❌ Digite um nome para o pack!"), Color(0.9, 0.2, 0.2, 1))
		return
	
	if pack.get("cards", []).size() == 0:
		_show_toast(LocalizationManager.translate("custom_pack_error_no_cards", "❌ Adicione pelo menos 1 carta!"), Color(0.9, 0.2, 0.2, 1))
		return
	
	_save_pack(pack)
	_show_toast(LocalizationManager.translate("custom_pack_saved", "✅ Pack salvo com sucesso!"), Color(0.3, 0.9, 0.3, 1))
	
	# Vibrar sucesso
	UIManager.safe_vibrate(100)
	
	# Partículas de sucesso
	ParticlesManager.create_confetti(self, Vector2(540, 960), current_color)
	
	# Limpar campos
	name_input.text = ""
	cards_input.text = ""

func _on_back_pressed():
	UIManager.change_scene_with_fade("res://Scenes/pack_selector.tscn")

func _show_delete_confirmation(pack_name: String):
	# Fundo escuro
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.size = get_viewport_rect().size
	bg.z_index = 300
	add_child(bg)
	
	# Painel glassmorphism
	var panel = UIManager.create_glassmorphism_panel(
		Vector2(900, 600),
		Vector2(90, 660),
		Color(0.1, 0.1, 0.1, 0.95)
	)
	panel.z_index = 301
	add_child(panel)
	
	var vb = VBoxContainer.new()
	vb.size = panel.size
	vb.add_theme_constant_override("separation", 30)
	panel.add_child(vb)
	
	# Ícone de aviso
	var icon = Label.new()
	icon.text = "!"
	icon.add_theme_font_size_override("font_size", 80)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(icon)
	
	# Título
	var title = Label.new()
	title.text = LocalizationManager.translate("custom_pack_delete_title", "Deletar Pack?")
	var ls = LabelSettings.new()
	ls.font_size = 48
	ls.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	ls.font_color = Color(1, 0.3, 0.3, 1)
	title.label_settings = ls
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	
	# Mensagem
	var msg = Label.new()
	msg.text = LocalizationManager.translate("custom_pack_delete_message", 'Tem certeza que deseja deletar\n"%s"?\n\nEsta ação não pode ser desfeita!') % pack_name
	var msg_ls = LabelSettings.new()
	msg_ls.font_size = 32
	msg_ls.font_color = Color(0.9, 0.9, 0.9, 1)
	msg.label_settings = msg_ls
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(msg)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	vb.add_child(spacer)
	
	# Botões
	var hb = HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 30)
	
	var cancel = Button.new()
	cancel.text = LocalizationManager.translate("custom_pack_delete_cancel", "❌ Cancelar")
	cancel.custom_minimum_size = Vector2(300, 80)
	var cancel_style = StyleBoxFlat.new()
	cancel_style.bg_color = Color(0.3, 0.3, 0.3, 1)
	cancel_style.set_corner_radius_all(15)
	cancel.add_theme_stylebox_override("normal", cancel_style)
	cancel.add_theme_stylebox_override("hover", cancel_style)
	
	var confirm = Button.new()
	confirm.text = LocalizationManager.translate("custom_pack_delete_confirm", "Deletar")
	confirm.custom_minimum_size = Vector2(300, 80)
	var confirm_style = StyleBoxFlat.new()
	confirm_style.bg_color = Color(0.9, 0.2, 0.2, 1)
	confirm_style.set_corner_radius_all(15)
	confirm.add_theme_stylebox_override("normal", confirm_style)
	confirm.add_theme_stylebox_override("hover", confirm_style)
	
	hb.add_child(cancel)
	hb.add_child(confirm)
	vb.add_child(hb)
	
	# Animar entrada
	UIManager.animate_panel_entrance(panel)
	
	# Conectar botões
	cancel.pressed.connect(func():
		bg.queue_free()
		panel.queue_free()
	)
	
	confirm.pressed.connect(func():
		_delete_pack(pack_name)
		bg.queue_free()
		panel.queue_free()
		
		_show_toast(LocalizationManager.translate("custom_pack_deleted", "✅ Pack deletado!"), Color(0.3, 0.9, 0.3, 1))
		UIManager.safe_vibrate(100)
		
		# Atualizar lista
		_refresh_pack_list()
	)

func _delete_pack(pack_name: String):
	var file_path = "user://custom_packs.json"
	if not FileAccess.file_exists(file_path):
		return
	
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return
	
	var txt = f.get_as_text()
	f.close()
	var data = JSON.parse_string(txt)
	
	if typeof(data) == TYPE_DICTIONARY and data.has("packs"):
		var new_packs = []
		for pack in data.packs:
			if pack.get("name", "") != pack_name:
				new_packs.append(pack)
		
		data.packs = new_packs
		
		var wf = FileAccess.open(file_path, FileAccess.WRITE)
		wf.store_string(JSON.stringify(data, "\t"))
		wf.close()

func _build_pack_dict() -> Dictionary:
	var nm = name_input.text.strip_edges()
	if nm == "":
		nm = LocalizationManager.translate("custom_pack_default_name", "Pack Personalizado")
	
	var lines: Array = cards_input.text.split("\n")
	var cards: Array[String] = []
	for l in lines:
		var t = (l as String).strip_edges()
		if t != "":
			cards.append(t)
	
	return {
		"name": nm,
		"color": current_color.to_html(),
		"cards": cards
	}

func _save_pack(pack: Dictionary):
	var file_path = "user://custom_packs.json"
	var data = {"packs": []}
	
	if FileAccess.file_exists(file_path):
		var rf = FileAccess.open(file_path, FileAccess.READ)
		if rf:
			var txt = rf.get_as_text()
			rf.close()
			var parsed = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("packs"):
				data = parsed
	
	# Atualizar (substituir se mesmo nome)
	var updated = false
	for i in range(data.packs.size()):
		if data.packs[i].get("name", "") == pack.get("name", ""):
			data.packs[i] = pack
			updated = true
			break
	
	if not updated:
		data.packs.append(pack)
	
	var wf = FileAccess.open(file_path, FileAccess.WRITE)
	wf.store_string(JSON.stringify(data, "\t"))
	wf.close()

func _load_all_packs() -> Array:
	var file_path = "user://custom_packs.json"
	if not FileAccess.file_exists(file_path):
		return []
	
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return []
	
	var txt = f.get_as_text()
	f.close()
	var data = JSON.parse_string(txt)
	
	if typeof(data) == TYPE_DICTIONARY and data.has("packs"):
		return data.packs
	
	return []

func _sanitize_filename(s: String) -> String:
	return s.replace(" ", "_").to_lower()

func _show_toast(msg: String, color: Color = Color(0.3, 0.9, 0.3, 1)):
	var lbl = Label.new()
	lbl.text = msg
	var ls = LabelSettings.new()
	ls.font_size = 38
	ls.font_color = color
	ls.outline_size = 6
	ls.outline_color = Color.BLACK
	lbl.label_settings = ls
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.z_index = 500
	add_child(lbl)
	
	await get_tree().process_frame
	
	if not is_instance_valid(lbl):
		return
	
	lbl.position = Vector2((get_viewport_rect().size.x - lbl.size.x) / 2.0, 200)
	
	lbl.modulate.a = 0.0
	lbl.scale = Vector2(0.8, 0.8)
	
	var tw = lbl.create_tween().set_parallel(true)
	tw.tween_property(lbl, "modulate:a", 1.0, 0.3)
	tw.tween_property(lbl, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
	
	await get_tree().create_timer(2.0).timeout
	
	if not is_instance_valid(lbl):
		return
	
	tw = lbl.create_tween()
	tw.tween_property(lbl, "modulate:a", 0.0, 0.4)
	await tw.finished
	
	if is_instance_valid(lbl):
		lbl.queue_free()
