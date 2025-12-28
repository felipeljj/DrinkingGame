extends Control

# Estado dos packs selecionados
var pack_state = {
	"classico": true,
	"insano": false,
}

var player_name: String = ""

func _ready():
	_apply_styles()
	_create_pack_cards()
	
	# Recuperar nome do jogador
	player_name = MultiplayerManager.game_settings.get("pending_player_name", "")

func _apply_styles():
	# Estilo do título
	$VBox/TitleLabel.add_theme_font_size_override("font_size", 50)
	$VBox/TitleLabel.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	# Botão Voltar
	$VBox/BackButton.flat = true
	$VBox/BackButton.add_theme_font_size_override("font_size", 32)
	
	# Botão Começar
	var start_style = StyleBoxFlat.new()
	start_style.bg_color = Color(1, 0.85, 0.3, 1)
	start_style.set_corner_radius_all(25)
	start_style.content_margin_left = 60
	start_style.content_margin_right = 60
	start_style.content_margin_top = 20
	start_style.content_margin_bottom = 20
	
	$VBox/StartButton.add_theme_stylebox_override("normal", start_style)
	$VBox/StartButton.add_theme_stylebox_override("hover", start_style)
	$VBox/StartButton.add_theme_stylebox_override("pressed", start_style)
	$VBox/StartButton.add_theme_font_size_override("font_size", 38)
	$VBox/StartButton.add_theme_color_override("font_color", Color(0, 0, 0, 1))

func _create_pack_cards():
	var packs = AbsurdCardsData.get_packs_info()
	
	for pack_info in packs:
		var card = _create_pack_card_ui(pack_info)
		$VBox/PacksGrid.add_child(card)

func _create_pack_card_ui(pack_info: Dictionary) -> Panel:
	var card = Panel.new()
	card.name = "Pack_" + pack_info.id
	card.custom_minimum_size = Vector2(450, 400)
	
	# Estilo do card - branco se disponível
	var card_style = StyleBoxFlat.new()
	if pack_info.available:
		card_style.bg_color = Color(0.15, 0.15, 0.15, 1)
		card_style.border_color = Color(1, 0.85, 0.3, 1)
	else:
		card_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
		card_style.border_color = Color(0.3, 0.3, 0.3, 0.5)
	card_style.set_corner_radius_all(25)
	card_style.border_width_left = 4
	card_style.border_width_right = 4
	card_style.border_width_top = 4
	card_style.border_width_bottom = 4
	card.add_theme_stylebox_override("panel", card_style)
	
	# VBox interno
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 25
	vbox.offset_top = 30
	vbox.offset_right = -25
	vbox.offset_bottom = -30
	vbox.add_theme_constant_override("separation", 15)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	# Ícone (texto em vez de emoji)
	var icon = Label.new()
	if pack_info.id == "classico":
		icon.text = "[C]"
	elif pack_info.id == "insano":
		icon.text = "[I]"
	else:
		icon.text = "[?]"
	icon.add_theme_font_size_override("font_size", 80)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon)
	
	# Nome do pack
	var name_label = Label.new()
	name_label.name = "name"
	name_label.text = pack_info.name
	name_label.add_theme_font_size_override("font_size", 40)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if not pack_info.available:
		name_label.modulate = Color(0.5, 0.5, 0.5, 1)
	vbox.add_child(name_label)
	
	# Descrição
	var desc_label = Label.new()
	desc_label.name = "description"
	desc_label.text = pack_info.description
	desc_label.add_theme_font_size_override("font_size", 22)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)
	
	# Contagem ou status
	var count_label = Label.new()
	if pack_info.available:
		count_label.text = str(pack_info.black_count) + " " + LocalizationManager.translate("pack_card_questions") + " - " + str(pack_info.white_count) + " " + LocalizationManager.translate("pack_card_answers")
	else:
		count_label.text = LocalizationManager.translate("pack_coming_soon")
	count_label.add_theme_font_size_override("font_size", 20)
	count_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(count_label)
	
	# Configurar interação apenas se disponível
	if pack_info.available:
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.gui_input.connect(func(event): _on_pack_gui_input(event, pack_info.id))
		
		# Estado visual inicial
		if pack_state.get(pack_info.id, false):
			card.modulate = Color(1, 1, 1, 1)
		else:
			card.modulate = Color(1, 1, 1, 0.5)
	else:
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.modulate = Color(1, 1, 1, 0.4)
	
	return card

func _on_pack_gui_input(event: InputEvent, pack_id: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_pack(pack_id)
	elif event is InputEventScreenTouch and event.pressed:
		_toggle_pack(pack_id)

func _toggle_pack(pack_id: String):
	pack_state[pack_id] = not pack_state[pack_id]
	UIManager.safe_vibrate(30)
	
	# Atualizar visual
	var card = $VBox/PacksGrid.get_node_or_null("Pack_" + pack_id)
	if card:
		if pack_state[pack_id]:
			# Selecionado
			var tween = create_tween()
			tween.tween_property(card, "modulate", Color(1, 1, 1, 1), 0.2)
			tween.parallel().tween_property(card, "scale", Vector2(1.05, 1.05), 0.1)
			tween.tween_property(card, "scale", Vector2.ONE, 0.1)
			
			# Efeito de partículas
			ParticlesManager.create_pulse_particles(self, card.global_position + card.size / 2, Color(1, 0.85, 0.3, 1))
		else:
			# Deselecionado
			var tween = create_tween()
			tween.tween_property(card, "modulate", Color(1, 1, 1, 0.5), 0.2)
	
	_update_start_button()

func _update_start_button():
	# Verificar se pelo menos um pack está selecionado
	var has_selection = false
	for pack_id in pack_state.keys():
		if pack_state[pack_id]:
			has_selection = true
			break
	
	$VBox/StartButton.disabled = not has_selection
	$VBox/StartButton.modulate.a = 1.0 if has_selection else 0.5

func _on_back_pressed():
	UIManager.safe_vibrate(30)
	UIManager.change_scene_with_fade("res://Scenes/absurd_cards_lobby.tscn")

func _on_start_pressed():
	# Verificar se algum pack está selecionado
	var selected_packs = []
	for pack_id in pack_state.keys():
		if pack_state[pack_id]:
			selected_packs.append(pack_id)
	
	if selected_packs.is_empty():
		return
	
	UIManager.safe_vibrate(50)
	
	# Salvar pack selecionado (usar primeiro por enquanto)
	MultiplayerManager.game_settings["pack"] = selected_packs[0]
	
	# Criar sala
	var code = MultiplayerManager.create_room(player_name)
	if code.is_empty():
		return
	
	# Ir para o lobby
	UIManager.change_scene_with_fade("res://Scenes/absurd_cards_lobby.tscn")
