extends Control

var pack_state = {}

var card_data = {
	"leve": [
		"...fingi estar dormindo para não atender uma ligação",
		"...stalkeei o perfil de alguém por mais de 30 minutos",
		"...cantei no chuveiro achando que ninguém ouvia",
		"...menti sobre minha idade",
		"...fingi não ver alguém que conhecia na rua",
		"...dei desculpa para não sair de casa",
		"...fiz amizade só por interesse",
		"...chorei vendo filme romântico",
		"...fingi gostar de um presente",
		"...li mensagem e não respondi de propósito",
		"...culpei outra pessoa por algo que eu fiz",
		"...menti no currículo",
		"...fingi que entendia algo quando não entendia",
		"...esqueci o aniversário de alguém importante",
		"...fiz promessa de ano novo que não cumpri",
		"...dei unfollow em alguém por ciúmes",
		"...chorei por causa de série ou novela",
		"...fingi estar ocupado para evitar alguém",
		"...guardei segredo que era pra contar",
		"...fiz dieta que durou menos de uma semana",
		"...comprei algo só porque estava em promoção",
		"...fingi que tinha lido um livro",
		"...menti sobre quanto custou algo",
		"...dei conselho que eu mesmo não sigo",
		"...fingi estar bem quando não estava",
	],
	"festeiro": [
		"...vomitei em uma festa",
		"...perdi a memória por causa de bebida",
		"...acordei sem saber como cheguei em casa",
		"...bebi de ressaca",
		"...misturei bebidas e me arrependi",
		"...dancei em cima de uma mesa",
		"...fui embora de uma festa sem avisar ninguém",
		"...fiquei bêbado antes da festa começar",
		"...mandei mensagem bêbado que me arrependi depois",
		"...liguei para o ex bêbado",
		"...dormi em lugar aleatório numa festa",
		"...paguei uma rodada pra todo mundo",
		"...entrei em festa sem ser convidado",
		"...fui barrado na entrada de algum lugar",
		"...perdi celular, carteira ou chave em festa",
		"...fiz amizade com estranho no banheiro",
		"...pedi desculpa no dia seguinte sem lembrar o que fiz",
		"...fui a última pessoa a sair da festa",
		"...bebi mais que aguento só pra impressionar",
		"...fiz previa melhor que a festa em si",
		"...dormi na festa",
		"...chorei bêbado",
		"...briguei bêbado",
		"...fui expulso de algum lugar",
		"...acordei com ressaca no trabalho/faculdade",
	],
	"relacionamentos": [
		"...stalkeei o ex nas redes sociais",
		"...voltei com ex",
		"...fiquei com amigo(a) de ex",
		"...tive crush em professor(a)",
		"...mandei nude",
		"...fui rejeitado(a) no pedido de namoro",
		"...terminei por mensagem",
		"...fiquei com mais de uma pessoa na mesma noite",
		"...dei fora em alguém de forma grossa",
		"...fiquei com alguém só por carência",
		"...chorei por amor",
		"...fiz declaração de amor bêbado(a)",
		"...fiquei com alguém que nem sabia o nome",
		"...menti sobre quantidade de pessoas que já fiquei",
		"...tive ciúmes de amigo(a) do(a) parceiro(a)",
		"...dei match e não puxei conversa",
		"...fui iludido(a)",
		"...iludi alguém",
		"...fiquei com alguém comprometido(a)",
		"...criei fake para stalkear",
		"...descobri traição",
		"...perdoei traição",
		"...fiquei com melhor amigo(a) de alguém",
		"...terminei e voltei mais de 3 vezes",
		"...menti dizendo que estava solteiro(a)",
	],
	"ousado": [
		"...fiz algo em lugar público que não deveria",
		"...fui pego(a) no flagra",
		"...menti sobre experiência na hora H",
		"...fingi prazer",
		"...fiz sexting",
		"...tive fantasia com alguém dessa roda",
		"...já pensei em alguém dessa roda de forma...",
		"...fiz strip tease",
		"...usei algum brinquedo adulto",
		"...fiz roleplay",
		"...gravei algo íntimo",
		"...fiz em lugar inusitado",
		"...fui para motel",
		"...experimentei algo diferente no quarto",
		"...tive mais de um parceiro ao mesmo tempo",
		"...menti sobre número de parceiros",
		"...fiz algo só porque estava bêbado",
		"...me arrependi de algo na hora H",
		"...fingi orgasmo",
		"...fiz sexo casual e não contei pra ninguém",
		"...tive crush em chefe ou colega de trabalho",
		"...já fiquei com alguém muito mais velho(a)",
		"...já fiquei com alguém muito mais novo(a)",
		"...fiz algo que só vi em filme adulto",
		"...tive encontro de uma noite só",
	],
}

var displayed_texts = {}
var panel_freed = false

@onready var card_panel = $CardPanel
@onready var card_label = $CardPanel/CardLabel
@onready var eu_nunca_label = $CardPanel/EuNuncaLabel
@onready var hint_label = $CardPanel/HintLabel
@onready var generate_button = $GenerateButton
@onready var history_button = $TopButtons/Historico
@onready var sair_button = $Sair

# Variáveis para gestos de deslizar
var touch_start_position = Vector2.ZERO
var is_dragging = false
var drag_threshold = 100.0
var card_original_position = Vector2.ZERO
var is_animating = false
var tween: Tween
var card_shadow: ColorRect
var original_scale = Vector2.ONE

# Histórico
var card_history: Array = []
var current_history_index: int = -1

func _ready():
	# Manter tela sempre ligada
	DisplayServer.screen_set_keep_on(true)
	
	for category in card_data.keys():
		displayed_texts[category] = []
	
	if card_panel:
		card_original_position = card_panel.position
		original_scale = card_panel.scale
		_create_card_shadow()
		card_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		card_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Adicionar partículas
	ParticlesManager.create_bubble_particles(self)
	
	# Adicionar hover effects
	UIManager.add_button_hover_effect(generate_button)
	UIManager.add_button_hover_effect(history_button)
	UIManager.add_button_hover_effect(sair_button)
	
	# Aplicar glassmorphism nos botões do topo
	_apply_glassmorphism_to_top_buttons()
	
	# Atualizar textos
	_update_ui_texts()
	
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Gerar primeira carta
	generate_card()

func _apply_glassmorphism_to_top_buttons():
	var top_buttons = $TopButtons
	if not top_buttons:
		return
	
	for child in top_buttons.get_children():
		if child is Button:
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.1, 0.2, 0.4, 0.6)
			style.set_corner_radius_all(20)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			style.border_color = Color(0.3, 0.5, 0.8, 0.5)
			child.add_theme_stylebox_override("normal", style)
			child.add_theme_stylebox_override("hover", style)
			child.add_theme_stylebox_override("pressed", style)

func _update_ui_texts():
	if eu_nunca_label:
		eu_nunca_label.text = LocalizationManager.translate("never_prefix", "EU NUNCA...")
	if hint_label:
		hint_label.text = LocalizationManager.translate("never_hint", "Quem já fez, bebe!")
	if history_button:
		history_button.text = LocalizationManager.translate("never_history", "Histórico")
	if sair_button:
		sair_button.text = LocalizationManager.translate("never_exit", "SAIR")

func _create_card_shadow():
	if not card_panel: return
	if card_shadow and is_instance_valid(card_shadow): card_shadow.queue_free()
	
	card_shadow = ColorRect.new()
	card_shadow.color = Color(0, 0, 0, 0.3)
	card_shadow.size = card_panel.size
	card_shadow.position = card_panel.position + Vector2(10, 10)
	card_shadow.z_index = card_panel.z_index - 1
	card_shadow.scale = card_panel.scale
	card_shadow.rotation = card_panel.rotation
	card_panel.get_parent().add_child(card_shadow)

func _input(event):
	if panel_freed or is_animating: return

	if (event is InputEventScreenTouch and event.pressed) or \
	   (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		touch_start_position = event.position
		is_dragging = true

	elif (event is InputEventScreenTouch and not event.pressed) or \
		 (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		if is_dragging:
			is_dragging = false
			_handle_swipe_gesture()

	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and is_dragging and card_panel:
		var current_pos = event.position
		var drag_distance_x = current_pos.x - touch_start_position.x
		card_panel.position.x = card_original_position.x + drag_distance_x
		
		if card_shadow:
			card_shadow.position.x = card_panel.position.x + 10
			card_shadow.position.y = card_panel.position.y + 10

func _handle_swipe_gesture():
	if not card_panel: return

	var swipe_distance = card_panel.position.x - card_original_position.x
	if abs(swipe_distance) > drag_threshold:
		_animate_card_swipe(swipe_distance)
	else:
		_reset_card_position()

func _animate_card_swipe(distance):
	is_animating = true
	var direction = 1 if distance > 0 else -1
	var viewport_width = get_viewport().size.x

	if not is_instance_valid(card_panel) or not card_panel.is_inside_tree():
		is_animating = false
		return

	if tween and is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	if not tween:
		is_animating = false
		return
	tween.set_parallel(true)
	tween.tween_property(card_panel, "position:x", card_original_position.x + (direction * viewport_width), 0.3)
	tween.tween_property(card_panel, "modulate:a", 0.0, 0.2)
	if card_shadow and is_instance_valid(card_shadow):
		tween.tween_property(card_shadow, "position:x", card_original_position.x + (direction * viewport_width), 0.3)
		tween.tween_property(card_shadow, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	
	if panel_freed or not is_instance_valid(card_panel):
		is_animating = false
		return
	
	# Swipe esquerda = nova carta, Swipe direita = carta anterior
	if distance < 0:
		current_history_index = -1
		generate_card()
	else:
		_show_previous_card()
	
	if panel_freed:
		is_animating = false
		return
	
	# Animação de entrada
	if not is_instance_valid(card_panel):
		is_animating = false
		return
		
	card_panel.position.x = card_original_position.x - (direction * viewport_width)
	card_panel.rotation = 0.0
	card_panel.modulate.a = 0.0
	if card_shadow and is_instance_valid(card_shadow):
		card_shadow.position.x = card_original_position.x - (direction * viewport_width) + 10
		card_shadow.rotation = 0.0
		card_shadow.modulate.a = 0.0

	if not is_instance_valid(card_panel) or not card_panel.is_inside_tree():
		is_animating = false
		return
		
	tween = create_tween()
	if not tween:
		is_animating = false
		return
	tween.set_parallel(true)
	tween.tween_property(card_panel, "position", card_original_position, 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_panel, "modulate:a", 1.0, 0.4)
	if card_shadow and is_instance_valid(card_shadow):
		tween.tween_property(card_shadow, "position", card_original_position + Vector2(10, 10), 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_shadow, "modulate:a", 0.3, 0.4)
	
	await tween.finished
	is_animating = false

func _show_previous_card():
	if card_history.is_empty():
		return
	
	if current_history_index == -1:
		if card_history.size() >= 2:
			current_history_index = card_history.size() - 2
		else:
			return
	else:
		if current_history_index > 0:
			current_history_index -= 1
		else:
			return
	
	var history_card = card_history[current_history_index]
	if card_label and is_instance_valid(card_label):
		card_label.text = history_card.text
		_adjust_card_text_size()

func _reset_card_position():
	if not card_panel or not is_instance_valid(card_panel) or not card_panel.is_inside_tree():
		return
	
	if tween and is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	if not tween:
		return
	tween.set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_panel, "position", card_original_position, 0.2)
	if card_shadow and is_instance_valid(card_shadow):
		tween.tween_property(card_shadow, "position", card_original_position + Vector2(10, 10), 0.2)

func generate_card():
	if panel_freed: return
	
	var available_categories = pack_state.keys().filter(func(p): return pack_state[p])
	var available_cards_exist = false
	
	for category in available_categories:
		if card_data.has(category):
			if not displayed_texts.has(category):
				displayed_texts[category] = []
			if displayed_texts[category].size() < card_data[category].size():
				available_cards_exist = true
				break
	
	# Se não há cartas, resetar
	if not available_cards_exist:
		for category in displayed_texts.keys():
			displayed_texts[category] = []
		available_cards_exist = true
	
	if available_cards_exist:
		var category
		while true:
			category = available_categories.pick_random()
			if not card_data.has(category):
				continue
			if not displayed_texts.has(category):
				displayed_texts[category] = []
			if displayed_texts[category].size() < card_data[category].size():
				break
		
		var unused_texts = card_data[category].filter(func(text): return not text in displayed_texts[category])
		var selected_text = unused_texts.pick_random()
		
		if card_label and is_instance_valid(card_label):
			card_label.text = selected_text
			_adjust_card_text_size()
		
		# Adicionar ao histórico
		card_history.append({
			"text": selected_text,
			"category": category,
			"timestamp": Time.get_ticks_msec()
		})
		
		displayed_texts[category].append(selected_text)
	else:
		if card_label:
			card_label.text = LocalizationManager.translate("never_end", "Acabaram as cartas! Que tal recomeçar?")

func _adjust_card_text_size():
	if not card_label or not is_instance_valid(card_label):
		return
	
	var text_length = card_label.text.length()
	var base_size = 55
	
	if text_length > 100:
		base_size = 42
	elif text_length > 70:
		base_size = 48
	elif text_length > 40:
		base_size = 52
	
	var settings = card_label.label_settings
	if settings:
		settings.font_size = base_size

func _on_generate_pressed() -> void:
	current_history_index = -1
	generate_card()
	
	# Animação do botão
	if generate_button and is_instance_valid(generate_button):
		var btn_tween = generate_button.create_tween()
		btn_tween.tween_property(generate_button, "scale", Vector2(1.2, 1.2), 0.1)
		btn_tween.tween_property(generate_button, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)

func _on_historico_pressed() -> void:
	_show_history_popup()

func _on_sair_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/never_have_i_ever_selector.tscn")

func _show_history_popup():
	if card_history.is_empty():
		return
	
	var popup = UIManager.create_glassmorphism_panel(
		Vector2(800, 1000),
		Vector2(140, 300),
		Color(0.05, 0.1, 0.2, 0.95)
	)
	popup.z_index = 300
	add_child(popup)
	
	var vbox = VBoxContainer.new()
	vbox.layout_mode = 1
	vbox.anchors_preset = Control.PRESET_FULL_RECT
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 15)
	popup.add_child(vbox)
	
	# Título
	var title = Label.new()
	title.text = LocalizationManager.translate("never_history_title", "Histórico de Cartas")
	var title_settings = LabelSettings.new()
	title_settings.font_size = 40
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title.label_settings = title_settings
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Scroll com cartas
	var scroll = ScrollContainer.new()
	scroll.layout_mode = 2
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var cards_vbox = VBoxContainer.new()
	cards_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(cards_vbox)
	
	# Mostrar últimas 20 cartas (mais recentes primeiro)
	var recent_cards = card_history.slice(-20)
	recent_cards.reverse()
	
	for i in range(recent_cards.size()):
		var card = recent_cards[i]
		var label = Label.new()
		label.text = str(recent_cards.size() - i) + ". EU NUNCA " + card.text
		var label_settings = LabelSettings.new()
		label_settings.font_size = 28
		label.label_settings = label_settings
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cards_vbox.add_child(label)
	
	# Botão fechar
	var close_btn = Button.new()
	close_btn.text = LocalizationManager.translate("never_close", "Fechar")
	close_btn.add_theme_font_size_override("font_size", 36)
	close_btn.pressed.connect(func():
		if is_instance_valid(popup):
			var fade_tween = create_tween()
			fade_tween.tween_property(popup, "modulate:a", 0.0, 0.3)
			await fade_tween.finished
			popup.queue_free()
	)
	vbox.add_child(close_btn)
	
	UIManager.animate_panel_entrance(popup)
